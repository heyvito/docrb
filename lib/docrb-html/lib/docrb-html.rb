# frozen_string_literal: true

require "json"

require "erb"
require "sassc"
require "nokogiri"
require "redcarpet"
require "rouge"
require "rouge/plugins/redcarpet"

require_relative "renderer/version"
require_relative "renderer/core_extensions"
require_relative "renderer/markdown"

class Renderer
  ASSETS_PATH = Pathname.new(__dir__).join("../assets")
  TEMPLATES_PATH = Pathname.new(__dir__).join("../templates")
  STYLE_BASE = SassC::Engine.new(File.read(ASSETS_PATH.join("style.scss")),
    style: :compressed,
    load_paths: [ASSETS_PATH]).render
end

require_relative "renderer/template"
require_relative "renderer/component"
require_relative "renderer/helpers"
require_relative "renderer/page"
require_relative "renderer/metadata"
require_relative "renderer/entities"

class Renderer
  attr_reader :spec

  def now = Time.now.strftime("%A, %-d %b %Y %H:%M:%S %Z")

  def output_path(*args) = File.join(@output, *args.map(&:to_s))

  def initialize(source, spec, output)
    @output = output
    @footer = Component::Footer.new(version: VERSION, updated_at: now)
    @spec = spec
    @source = source
    Helpers.current_renderer = self
  end

  def git_url(loc)
    url = @spec[:git_url]
    tip = @spec[:git_tip]
    filename = clean_file_path(loc)
    "#{url}/blob/#{tip}#{filename}#L#{loc.line_start}"
  end

  def clean_file_path(definition) = definition.file_path.gsub(@spec[:git_root], "")

  def make_outline
    (@source.nodes.by_kind(:module) + @source.nodes.by_kind(:class))
      .map { outline(_1) }
  end

  def make_path(*args)
    root = spec.fetch(:base_path, "/")
    File.join(root, *args.flatten.map(&:to_s))
  end

  def outline(object, level = 0)
    {
      level:,
      object:,
      classes: object.classes.map { outline(_1, level + 1) },
      modules: object.modules.map { outline(_1, level + 1) }
    }
  end

  def render
    project_header = Component::ProjectHeader.new(
      name: @spec[:name],
      description: @spec[:summary],
      license: @spec[:license],
      owner: Metadata.format_authors(@spec[:authors]),
      links: Metadata.project_links(@spec)
    )

    readme = if @spec[:readme]
      Component::Markdown.new(source: Markdown.render(@spec[:readme]))
    else
      Component::Markdown.new(source: "<div class=\"html\">" \
                                      "<div class=\"faded\">This project does not contain a README.</div></div>")
    end

    index = Page.new(title: "#{@spec[:name]} - Docrb") do
      [
        project_header,
        Component::TabBar.new(
          selected_index: 0,
          items: [
            { name: "Readme", href: make_path("/") },
            { name: "Components", href: make_path("/components.html") }
          ]
        ),
        readme,
        @footer
      ]
    end

    components = Page.new(title: "Components - #{@spec[:name]} - Docrb") do
      [
        project_header,
        Component::TabBar.new(
          selected_index: 1,
          items: [
            { name: "Readme", href: make_path("/") },
            { name: "Components", href: make_path("/components.html") }
          ]
        ),
        Component::ComponentList.new(list: make_outline),
        @footer
      ]
    end

    pages(@source.nodes.by_kind(:class, :module))

    FileUtils.mkdir_p @output

    index.render_to(output_path("index.html"))
    components.render_to(output_path("components.html"))
    File.write(output_path("style.css"), STYLE_BASE)

    copy_assets
  end

  def copy_assets
    [
      "js/filtering.js",
      "favicon.ico"
    ].each do |file|
      File.write(output_path(File.basename(file)),
        File.read(ASSETS_PATH.join(file)))
    end
  end

  def pages(comps, parents = [])
    comps.each do |comp|
      title = "#{comp.name} - #{@spec[:name]} - Docrb"
      page = Page.new(title:, level: parents.count) do
        [
          Component::ClassHeader.new(
            type: comp.kind,
            name: comp.name,
            definitions: comp.defined_by.map do |by|
              {
                filename: File.basename(by.file_path),
                git_url: git_url(by)
              }
            end
          ),
          Component::Breadcrumb.new(
            project_name: @spec[:name],
            items: (parents + [comp]).map.with_index do |p, idx|
              { name: p.name, parents: parents[0...idx].map(&:name) }
            end
          ),
          Component::DocBox.new(
            item: comp,
            meta: @spec
          ),
          @footer
        ]
      end

      parent_dir = output_path(*parents.map(&:name))
      FileUtils.mkdir_p(parent_dir)
      page.render_to(File.join(parent_dir, "#{comp.name}.html"))

      pages(comp.classes + comp.modules, parents + [comp])
    end
  end
end
