import React from 'react';

import { Icon, iconNames } from '@/components/icon';

export default {
  title: 'Basic/Icon',
  component: Icon,
  argTypes: {
    name: {
      options: iconNames,
      control: { type: 'select' }
    }
  },
  decorators: [(story, context) => (
    <div style={{
      padding: '1rem',
      display: 'flex',
    }}>
      <div style={{
        border: context.args.showBounds ? '1px solid rgba(255, 255, 255, 0.4)' : '1px solid transparent'
      }}>
        {story()}
      </div>
    </div>
  )],
};

export const Basic = (args) => <Icon {...args} />;

Basic.args = {
  name: iconNames[0],
  size: "auto",
  showBounds: false
};
