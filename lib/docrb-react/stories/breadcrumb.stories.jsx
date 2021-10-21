import React from 'react';

import { Breadcrumb } from '@/components/breadcrumb';

export default {
  title: 'Basic/Breadcrumb',
  component: Breadcrumb,
};

export const Basic = (args) => <Breadcrumb {...args} />;

Basic.args = {
  projectName: "Docrb",
  items: [
    { name: "Foo", parents: [] },
    { name: "Bar", parents: ["Foo"] },
    { name: "Baz", parents: ["Foo", "Bar"] },
    { name: "Baz", parents: ["Foo", "Bar"] },
    { name: "Baz", parents: ["Foo", "Bar"] },
    { name: "Baz", parents: ["Foo", "Bar"] },
    { name: "Baz", parents: ["Foo", "Bar"] },
    { name: "Baz", parents: ["Foo", "Bar"] },
    { name: "Baz", parents: ["Foo", "Bar"] },
    { name: "Baz", parents: ["Foo", "Bar"] },
    { name: "Baz", parents: ["Foo", "Bar"] },
    { name: "Baz", parents: ["Foo", "Bar"] },
    { name: "Baz", parents: ["Foo", "Bar"] },
    { name: "Baz", parents: ["Foo", "Bar"] },
    { name: "Baz", parents: ["Foo", "Bar"] },
    { name: "Baz", parents: ["Foo", "Bar"] },
    { name: "Baz", parents: ["Foo", "Bar"] },
  ]
}
