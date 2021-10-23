import React from 'react';

import {
  Text,
  Heading,
  LinkColumn,
  HorizontalContainer, Unresolved, ClassDetails,
} from "@/components/documentation";
import { Link } from "@/components/link";
import { Icon } from "@/components/icon";

export default {
  title: 'Documentation/Components',
};

export const TextExample = () => <Text>Some content here</Text>;

export const HeadingExample = () => <Heading>Some title here</Heading>;

export const LinkColumnExample = () => <LinkColumn>
  <div><Link href="https://github.com/heyvito/docrb" text="Link A" /></div>
  <div><Link href="https://github.com/heyvito/docrb" text="Link B" /></div>
</LinkColumn>;

export const HorizontalContainerExample = () => <HorizontalContainer><Icon name="questionmark"/> <Text>Some content</Text></HorizontalContainer>

export const UnresolvedExample = () => <Unresolved obj={{ contents: "SomeSymbol" }} />;
