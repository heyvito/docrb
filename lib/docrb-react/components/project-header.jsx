import React from 'react';
import { Label } from '@/components/docrb-label';
import { Link } from '@/components/link';
import { Text } from '@/components/text';
import { Icon } from "@/components/icon"

import { Margin } from '@/styles/positioning';
import { Base, Project, RightSide, LinkPanel, LinkRow } from '@/styles/header';

export const ProjectHeader = ({ name, description, owner, license, links }) => (
  <Base>
    <Project>
      <h1>{name}</h1>
      <h3>{description}</h3>
    </Project>
    <RightSide>
      <Label/>
      <Margin top="30">
        <LinkPanel>
          {owner && (
            <LinkRow>
              <Text>{owner}</Text>
              <Margin left="8">
                <Icon name="user" size="22"/>
              </Margin>
            </LinkRow>)}
          {license && (
            <LinkRow>
              <Text>{license}</Text>
              <Margin left="8">
                <Icon name="balance" size="22"/>
              </Margin>
            </LinkRow>)}
          {links && links.map(i =>
            <LinkRow key={i.href}>
              <Link kind="dashed" href={i.href} text={i.href.replace(/^https?:\/\//, '')}/>
              <Margin left="8">
                <Icon name={i.kind} size="22"/>
              </Margin>
            </LinkRow>)}
        </LinkPanel>
      </Margin>
    </RightSide>
  </Base>
);
