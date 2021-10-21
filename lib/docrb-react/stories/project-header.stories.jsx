import React from 'react';

import { ProjectHeader } from '@/components/project-header';

export default {
  title: 'Header/Project',
  component: ProjectHeader,
};

const Template = (args) => <ProjectHeader {...args} />;

export const Default = Template.bind({});
Default.args = {
   name: 'Logrb',
   description: 'Small logger inspired by Go\'s Zap',
   owner: 'Victor Gama',
   license: 'MIT',
   links: [
    { kind: 'rubygems', href: 'https://rubygems.org/gems/logrb' },
    { kind: 'github', href: 'https://github.com/heyvito/logrb' }
   ]
};
