import React from 'react';

import { ClassHeader } from '@/components/class-header';

export default {
  title: 'Header/Class',
  component: ClassHeader,
};

const Template = (args) => <ClassHeader {...args} />;

export const Default = Template.bind({});
Default.args = {
   type: 'Class',
   name: 'Docrb',
  definitions: [{ name: "Docrb.rb", href: ""}, { name: "Foobar.rb", href: ""}]
};
