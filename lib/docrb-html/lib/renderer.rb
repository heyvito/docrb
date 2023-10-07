# frozen_string_literal: true

require "json"

require "erb"
require "sassc"
require "nokogiri"

require_relative "renderer/version"
require_relative "renderer/core_extensions"

class Renderer
  ASSETS_PATH = Pathname.new(__dir__).join("../assets")
  TEMPLATES_PATH = Pathname.new(__dir__).join("../templates")
  STYLE_BASE = SassC::Engine.new(File.read(ASSETS_PATH.join("style.scss")),
    style: :compressed,
    load_paths: [ASSETS_PATH]).render

  def now = Time.now.strftime("%A, %-d %b %Y %H:%M:%S %Z")

  def initialize(base, output)
    @base = Pathname.new(base)
    @output = Pathname.new(output)
  end

  def metadata = @metadata ||= Metadata.new(@base)

  def defs = @defs ||= Defs.new(@base, metadata)

  def footer = @footer ||= Component::Footer.new(version: VERSION, updated_at: now)

  def render
    project_header = Component::ProjectHeader.new(
      name: metadata.name,
      description: metadata.summary,
      license: metadata.license,
      owner: metadata.format_authors,
      links: metadata.project_links
    )

    index = Page.new(title: "#{metadata.name} - Docrb") do
      [
        project_header,
        Component::TabBar.new(
          selected_index: 0,
          items: [
            { name: "Readme", href: "/" },
            { name: "Components", href: "/components.html" }
          ]
        ),
        Component::Markdown.new(source: File.read(@base.join("readme.html"))),
        footer
      ]
    end

    components = Page.new(title: "Components - #{metadata.name} - Docrb") do
      [
        project_header,
        Component::TabBar.new(
          selected_index: 1,
          items: [
            { name: "Readme", href: "/" },
            { name: "Components", href: "/components.html" }
          ]
        ),
        Component::ComponentList.new(list: defs.document_outline),
        footer
      ]
    end

    pages(defs.classes + defs.modules)

    FileUtils.mkdir_p @output

    index.render_to(@output.join("index.html"))
    components.render_to(@output.join("components.html"))
    File.write(@output.join("style.css"), STYLE_BASE)

    copy_assets
  end

  def copy_assets
    [
      "js/filtering.js",
      "favicon.ico"
    ].each do |file|
      File.write(@output.join(Pathname.new(file).basename),
        File.read(ASSETS_PATH.join(file)))
    end
  end

  def pages(comps, parents = [])
    comps.each do |comp|
      page = Page.new(
        title: "#{comp[:name]} - #{metadata.name} - Docrb",
        level: parents.count
      ) do
        [
          Component::ClassHeader.new(
            type: comp[:type],
            name: comp[:name],
            definitions: defs.definitions_of(comp)
          ),
          Component::Breadcrumb.new(
            project_name: metadata.name,
            items: (parents + [comp]).map.with_index do |p, idx|
              { name: p[:name], parents: parents[0...idx].map { _1[:name] } }
            end
          ),
          Component::DocBox.new(
            item: comp,
            meta: metadata,
            defs:
          ),
          footer
        ]
      end

      parent_dir = @output.join(parents.map { _1[:name] }.join("/"))
      FileUtils.mkdir_p(parent_dir)
      page.render_to(parent_dir.join("#{comp[:name]}.html"))

      pages(comp.fetch(:classes, []) + comp.fetch(:modules, []), parents + [comp])
    end
  end
end

require_relative "renderer/template"
require_relative "renderer/component"
require_relative "renderer/helpers"
require_relative "renderer/page"
require_relative "renderer/metadata"
require_relative "renderer/defs"
require_relative "renderer/entities"
