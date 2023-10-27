# frozen_string_literal: true

module Docrb
  RSpec.describe Parser::Computations do
    let(:parser) do
      Parser.new.tap do |p|
        base_dir = File.expand_path(File.join(__dir__, "..", "..", "..", "lib"))
        Dir[File.join(base_dir, "**", "*.rb")].each { p.parse(_1) }
      end
    end
    subject { Parser::Computations.new(parser) }

    it "groups containers" do
      subject.merge_containers(parser.nodes)
      path = %i[Docrb Parser MethodParameters Parameter]
      obj = parser.nodes.named(path.shift).first!
      until path.empty?
        obj = obj.classes.named(path.shift)
        expect(obj.length).to eq 1
        obj = obj.first!
      end
      expect(obj).to have_kind(:class) & be_named(:Parameter)
    end

    it "resolves references" do
      subject.merge_containers(parser.nodes)
      2.times { subject.resolve_references }
      ref = parser.nodes.named!(:Docrb).classes.named!(:Parser).classes.named!(:Class).inherits
      ref_id = parser.nodes.named!(:Docrb).classes.named!(:Parser).classes.named!(:Container).id
      expect(ref).to be_fulfilled
      expect(ref.resolved.id).to eq ref_id
    end

    describe "overrides" do
      it "resolves overrides" do
        subject.merge_containers(parser.nodes)
        2.times { subject.resolve_references }
        subject.resolve_overrides
        ref = parser.nodes.named!(:Docrb)
          .classes.named!(:Parser)
          .classes.named!(:Class)
          .instance_methods.named!(:unowned_classes)
        expect(ref.overriding).not_to be_nil
        expect(parser.object_by_id(ref.overriding).overridden_by).to include(ref.id)
      end

      it "do not duplicate methods" do
        subject.merge_containers(parser.nodes)
        2.times { subject.resolve_references }
        subject.resolve_overrides
        refs = parser.nodes.named!(:Docrb)
          .classes.named!(:Parser)
          .classes.named!(:Class)
          .all_instance_methods.named(:unowned_classes)
        expect(refs.length).to eq 1
      end
    end

    describe "flat paths" do
      let(:parser) { parse_fixture(35) }
      subject { Parser::Computations.new(parser) }

      it "unfurls flat paths" do
        subject.unfurl_locations
        subject.merge_containers(parser.nodes)
        2.times { subject.resolve_references }
        subject.unfurl_flat_paths
        expect(parser.nodes.length).to eq 1
        method = parser.nodes.named!(:Docrb)
          .modules.named!(:App)
          .classes.named!(:Calculator)
          .instance_methods.named(:sum)
          .first
        expect(method).not_to be_nil
      end
    end

    it "attaches documentation" do
      subject.unfurl_locations
      subject.merge_containers(parser.nodes)
      2.times { subject.resolve_references }
      subject.unfurl_flat_paths
      subject.resolve_overrides
      subject.resolve_deferred_singletons
      subject.attach_documentation
      target = parser.nodes
        .named!(:Docrb)
        .classes.named!(:Parser)
        .classes.named!(:CommentParser)
      expect(target.doc.dig(:value, 0, :value, 0, :value)).to eq "CommentParser"
    end

    describe "deferred singletons" do
      let(:parser) { parse_fixture(34) }
      subject { Parser::Computations.new(parser) }
      it "resolves deferred singletons" do
        subject.unfurl_locations
        subject.merge_containers(parser.nodes)
        2.times { subject.resolve_references }
        subject.unfurl_flat_paths
        subject.resolve_overrides
        subject.resolve_deferred_singletons
        subject.attach_documentation
        str = parser.nodes.named!(:String)
        expect(str).to have_kind :class
        expect(str.class_methods.length).to eq 1
        expect(str.class_methods.first).to be_named :sum
      end
    end
  end
end
