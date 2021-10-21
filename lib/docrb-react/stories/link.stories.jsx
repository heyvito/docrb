import React from 'react';

import { Link } from '@/components/link';
import { withNextRouter } from "storybook-addon-next-router";

export default {
  title: 'Basic/Link',
  component: Link,
  argTypes: {
    kind: {
      options: ['dotted', 'dashed'],
      control: { type: 'select' }
    }
  }
};

export const Basic = (args) => <Link {...args} />;

Basic.args = {
  text: "Link goes here",
  href: "/",
  kind: "dotted",
};

Basic.story = {
  parameters: {
    nextRouter: {
      path: '/',
      asPath: '/',
      query: {},
    },
  },
};
