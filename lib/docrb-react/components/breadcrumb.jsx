import React from 'react';
import NextLink from 'next/link';
import { Text } from '@/components/text';
import { Icon } from '@/components/icon';

import { Margin } from '@/styles/positioning';
import { Base, BaseLink } from '@/styles/breadcrumb';
import { ReactComponent as RawSeparator } from '@/images/breadcrumb_separator.svg';

const Link = ({ href, children }) => (
  <NextLink href={href}>
    <BaseLink>
      {children}
    </BaseLink>
  </NextLink>
);

const Separator = () => (
  <div>
    <RawSeparator />
  </div>
);

export const Breadcrumb = ({ projectName, items }) => (
  <Base>
    <Link href="/">
      <Icon name="home" size="15" />
      <Margin left={10} right={8}>
        <Text>{projectName}</Text>
      </Margin>
    </Link>
    {[{ name: 'Components', parents: [] }, ...items].map((i, idx) => (
      <React.Fragment key={i.name}>
        <Separator />
        <Link href={['/components', ...i.parents, idx === 0 ? '' : i.name].join('/')}>
          <Margin left={10} right={8}>
            <Text>{i.name}</Text>
          </Margin>
        </Link>
      </React.Fragment>
    ))}
  </Base>
);
