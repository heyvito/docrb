import React from 'react';

import { TabBar } from '@/components/tab-bar';
import { Markdown } from "@/components/markdown";
import { ProjectHeader } from '@/components/project-header';
import markdownContent from "./assets/markdown_generated.html";

export default {
  title: 'Implementation/Readme',
  component: Markdown,
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
		<TabBar items={["Readme", "Components"]} selectedIndex={0} />
		<Markdown html={markdownContent} />
	</div>
);

Basic.args = {};
