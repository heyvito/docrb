import React from 'react';

import { TabBar } from '@/components/tab-bar';
import { ProjectHeader } from '@/components/project-header';
import { ComponentList } from '@/components/component-listing';

export default {
  title: 'Implementation/Components',
  component: ProjectHeader,
};

const links = [
  { kind: 'rubygems', href: 'https://rubygems.org/gems/logrb' },
  { kind: 'github', href: 'https://github.com/heyvito/logrb' }
]

export const Basic = (args) => (
  <div>
    <ProjectHeader
      name="Logrb"
      description="Small logger inspired by Go's Zap"
      owner="Victor Gama"
      license="MIT"
      links={links} />
    <TabBar items={["Readme", "Components"]} selectedIndex={1} />
    <ComponentList list={args.list} />
  </div>
);

Basic.args = {
  list:  [
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
