import React from 'react';

import { ComponentList, TypeDefinition } from '@/components/component-listing';

export default {
  title: 'Basic/Component Listing'
};

export const Type_Definition = (args) => <TypeDefinition {...args} />;

Type_Definition.args = {
  name: "Logrb",
  type: "Class",
  href: "/"
};

export const List = (args) => <ComponentList {...args} />

List.args = {
  list: [
    {
      level: 0,
      name: "Foo",
      attributes: [
        { name: "attr1", type: "Attribute", visibility: "read/write" }
      ],
      methods: [
        { name: "def1", type: "Method", decoration: "inherited" }
      ],
      classes: [
        {
          level: 1,
          name: "Bar",
          attributes: [
            { name: "attr1", type: "Attribute", visibility: "read/write" }
          ],
          methods: [
            { name: "def1", type: "Method", decoration: "inherited" }
          ]
        }
      ]
    }
  ]
};
