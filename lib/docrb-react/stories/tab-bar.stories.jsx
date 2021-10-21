import React from 'react';

import { TabBar } from '@/components/tab-bar';

export default {
  title: 'Basic/TabBar',
  component: TabBar,
  argTypes: { onWantsSelectionChange: { action: 'onWantsSelectionChange' } }
};

export const Basic = (args) => <TabBar {...args} />;

Basic.args = {
  items: ["Readme", "Components"],
  selectedIndex: 0,
};
