import React from 'react';
import { MarkdownStyle } from '@/styles/markdown';

export const Markdown = ({ html }) => (
  <MarkdownStyle dangerouslySetInnerHTML={{ __html: html }} />
);
