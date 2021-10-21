import React from 'react';

import { Checkbox } from '@/components/checkbox';

export default {
  title: 'Basic/Checkbox',
  component: Checkbox,
};

export const Basic = (args) => <Checkbox {...args} />;

Basic.args = {
  label: "Show inherited members",
  checked: false
}
