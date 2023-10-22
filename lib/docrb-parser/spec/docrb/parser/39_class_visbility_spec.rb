# frozen_string_literal: true

RSpec.describe Docrb::Parser do
  subject { parse_fixture(39).nodes.first }

  context "visibility" do

    expected_members = {
      private: [
        [:instance_method, :pri_1],
        [:instance_method, :pri_2],
        [:instance_method, :pri_3],
        [:instance_method, :pri_4],
        [:instance_attribute, :foo, :writer],
        [:instance_attribute, :baz],
        [:class_method, :new],
        [:class_method, :class_priv],
      ],
      protected: [
        [:instance_method, :pro_1],
        [:instance_method, :pro_2],
      ],
      public: [
        [:method, :pub],
        [:method, :pub_1],
        [:method, :pub_2],
        [:instance_attribute, :foo, :reader],
        [:class_method, :class_pub],
      ]
    }

    expected_members.each do |kind, members|
      members.each do |member|
        type, name, extra = member
        it "parses #{type.to_s.split("_").join(" ")} #{name} #{extra ? "(#{extra}) " : nil}as #{kind}" do
          case type
          when :instance_method
            expect(subject.instance_methods.named(name).first!.visibility).to eq kind
          when :instance_attribute
            if extra.nil?
              expect(subject.instance_attributes.named(name).first!.reader_visibility).to eq kind
              expect(subject.instance_attributes.named(name).first!.writer_visibility).to eq kind
            else
              expect(subject.instance_attributes.named(name).first!.send("#{extra}_visibility")).to eq kind
            end
          when :class_method
            expect(subject.class_methods.named(name).first!.visibility).to eq kind
          end
        end
      end
    end

  end
end
