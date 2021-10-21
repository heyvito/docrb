import React, { useState, useEffect } from 'react';
import { Label } from '@/components/docrb-label';
import { Link } from '@/components/link';
import { Icon } from "@/components/icon"
import { Checkbox } from "@/components/checkbox"

import {
  Base, Class, Type, Defs, RightSide, ClassName, DefLink,
  ChevronContainer, Toggles, Column
} from '@/styles/header';

export const ClassHeader = ({ type, name, definitions, filters = {}, onChangeFilter = () => {} }) => {
  const defs = [...definitions];
  let defCollection;
  if (definitions.length > 1) {
    const lastDef = defs.pop();
    const list = defs.map((i, idx) => <DefLink key={idx}><Link href={i.href} kind="dashed" text={i.name}/>, </DefLink>);
    defCollection = list.concat(<DefLink>and <Link href={lastDef.href} kind="dashed" text={lastDef.name}/> </DefLink>);
  } else if (definitions.length === 1) {
    const def = definitions[0];
    defCollection = (<DefLink><Link href={def.href} kind="dashed" text={def.name}/> </DefLink>);
  }

  const [collapsed, setCollapsed] = useState(true);
  const [currentFilters, setFilters] = useState({
    hideInternal: false,
    hidePrivate: false,
    hideAttributes: false,
    showInherited: true,
    showExtended: true,
    showIncluded: true,
    ...filters,
  });

  const toggleFilter = (named) => {
    return (newVal) => {
      setFilters(current => {
        return { ...current, [named]: newVal };
      });
    }
  };

  useEffect(() => {
    onChangeFilter(currentFilters)
  }, [currentFilters]);

  return (
    <Base>
      <Class>
        <Type>{type}</Type>
        <ClassName>{name}</ClassName>
        {defCollection &&
        <Defs>
          Defined in {defCollection}
        </Defs>
        }
        <ChevronContainer collapsed={collapsed} onClick={() => setCollapsed(prev => !prev)}>
          <Icon name="chevron"/> <span>{collapsed ? "Show More" : "Show Less"}</span>
        </ChevronContainer>
        <Toggles collapsed={collapsed}>
          <Column>
            <Checkbox checked={currentFilters.hideInternal} onChange={toggleFilter('hideInternal')}
                      label="Hide internal members"/>
            <Checkbox checked={currentFilters.hidePrivate} onChange={toggleFilter('hidePrivate')}
                      label="Hide private members"/>
          </Column>
          <Column>
            <Checkbox checked={currentFilters.hideAttributes} onChange={toggleFilter('hideAttributes')}
                      label="Hide attributes"/>
            <Checkbox checked={currentFilters.showInherited} onChange={toggleFilter('showInherited')}
                      label="Show inherited members"/>
          </Column>
          <Column>
            <Checkbox checked={currentFilters.showExtended} onChange={toggleFilter('showExtended')}
                      label="Show extended members"/>
            <Checkbox checked={currentFilters.showIncluded} onChange={toggleFilter('showIncluded')}
                      label="Show included members"/>
          </Column>
        </Toggles>
      </Class>
      <RightSide>
        <Label/>
      </RightSide>
    </Base>
  );
}
