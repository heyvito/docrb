import NextLink from 'next/link';
import React from 'react';
import { Linked } from '@/styles/common';

export const Link = ({ href, children }) => (
  <Linked className="linked-container">
    <NextLink href={href}>
      {children}
    </NextLink>
  </Linked>
);
