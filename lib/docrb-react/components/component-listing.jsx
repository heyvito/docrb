import React from 'react';
import { TypeName, ComponentListBase, Level } from '@/styles/component-listing';
import { Method } from '@/components/method';
import { Link } from '@/components/common';
import { Container, TypeDef } from '@/styles/common';

export const ClassModName = ({ href, children }) => (
  <Link href={href}>
    <TypeName>
      {children}
    </TypeName>
  </Link>
);

export const TypeDefinition = ({ type, name, href }) => (
  <Container>
    <TypeDef>{type}</TypeDef>
    <ClassModName href={href}>{name}</ClassModName>
  </Container>
);

export const ComponentList = ({ list, parents = [], omitMargins = false }) => (
  <ComponentListBase omitMargins={omitMargins}>
    {list && list.map((item, idx) => {
      const basePath = ['/components', ...parents, item.name].join('/');
      const newParents = [...parents, item.name];
      return (
        <Level level={item.level} key={idx}>
          <TypeDefinition type={item.type} href={basePath} name={item.name} />
          <Level level={item.level + 1}>
            {item.attributes.map((att) => (
              <Method
                key={att.name}
                type={att.type}
                name={att.name}
                visibility={att.visibility}
                decoration={att.decoration}
                href={[basePath, att.name].join('#')}
              />
            ))}
            {item.methods.map((method) => (
              <Method
                key={method.name}
                href={[basePath, method.name].join('#')}
                {...method}
              />
            ))}
          </Level>
          <ComponentList list={item.modules} omitMargins parents={newParents} />
          <ComponentList list={item.classes} omitMargins parents={newParents} />
        </Level>
      );
    })}
  </ComponentListBase>
);
