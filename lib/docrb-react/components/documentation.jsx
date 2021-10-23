import NextLink from 'next/link';
import React, { useState } from 'react';

import {
  BaseText,
  BaseHeading,
  BaseLinkColumn,
  BaseHorizontalContainer,
  BaseHTMLContent,
  Mono, Faded, AttributeContainer,
  SectionContainer, ToggleWrapper, SourceLink, SourceCode, FieldList, BaseReference, BaseUnresolved, FromBlock, Symbol,
} from '@/styles/documentation';
import { Link } from '@/components/link';
import { cleanFilePath, gitURL, pathOf } from '@/lib/index';
import { Label, ElementContainer } from '@/styles/method';
import { Method } from '@/components/method';
import { Margin } from '@/styles/positioning';
import { Icon } from '@/components/icon';

export const Text = ({ children }) => (
  <BaseText>
    {children}
  </BaseText>
);

export const Heading = ({ children }) => (
  <BaseHeading>
    {children}
  </BaseHeading>
);

export const LinkColumn = ({ children }) => (
  <BaseLinkColumn>
    {children}
  </BaseLinkColumn>
);

export const HorizontalContainer = ({ children }) => (
  <BaseHorizontalContainer>
    {children}
  </BaseHorizontalContainer>
);

export const Unresolved = ({ obj }) => (
  <BaseUnresolved title="Docrb could not resolve this reference. It may be from an external library or dynamically-generated method.">
    <Icon className="icon" name="questionmark" size={15} />
    {' '}
    <span>{obj.contents}</span>
  </BaseUnresolved>
);

const ChildStructure = ({ name, list }) => (
  list && list.length > 0 && (
    <div>
      <Heading>{name}</Heading>
      <LinkColumn>
        {list.map((i) => {
          let p = i.path;
          if (!p) {
            // This case may happen in a few specific cases in which specializeObject is processing a class that
            // inherits another one present in the same parent, but the sibling has not yet been specialised. I believe
            // this should be handled somehow by lib/index.js, but will keep this as a technical debt.
            p = pathOf(i);
          }

          return <div key={i.name}><Link href={['/components', ...p].join('/')} text={i.name} /></div>;
        })}
      </LinkColumn>
    </div>
  )
);

export const ClassDetails = ({ item, id }) => {
  const inherits = item.inherits ? [item.inherits] : [];
  return (
    <SectionContainer id={id}>
      <HorizontalContainer>
        <ChildStructure name="Inherits" list={inherits} />
        <ChildStructure name="Extends" list={item.extends} />
        <ChildStructure name="Includes" list={item.includes} />
        <ChildStructure name="Child Modules" list={item.modules} />
        <ChildStructure name="Child Classes" list={item.classes} />
      </HorizontalContainer>
    </SectionContainer>
  );
};

export const Markdown = ({ html, noMargin, inline }) => (
  <BaseHTMLContent dangerouslySetInnerHTML={{ __html: html }} noMargin={noMargin} inline={inline} />
);

export const Attribute = ({ item, label, decoration }) => (
  <AttributeContainer>
    {decoration && (
    <Icon
      className="decoration"
      name={decoration}
      size={12}
      title={decoration === 'inherited'
        ? 'Inherited'
        : 'Override'}
    />
    )}
    <Mono>{item.name}</Mono>
    <Label>{label}</Label>
    {item.doc ? <Markdown html={item.doc} /> : <Faded>(No documentation available)</Faded>}
  </AttributeContainer>
);

export const AttributeList = ({ list, id }) => {
  if (!list || list.length === 0) {
    return null;
  }

  return (
    <SectionContainer id={id}>
      <Heading>Attributes</Heading>
      {list
        .map((i) => <Attribute key={i.name} label={i.visibility} item={i} decoration={i.decoration} />)}
    </SectionContainer>
  );
};

const SourceBlock = ({ source }) => {
  const [expanded, setExpanded] = useState(false);
  const start = source.start_at; const
    end = source.end_at;
  let lineInfo;
  if (start === end) {
    lineInfo = `line ${start}`;
  } else {
    lineInfo = `lines ${start} to ${end}`;
  }
  return (
    <>
      <ToggleWrapper>
        <SourceLink onClick={() => setExpanded((prev) => !prev)}>
          {expanded ? 'Hide Source' : 'Show Source'}
        </SourceLink>
      </ToggleWrapper>
      <SourceCode expanded={expanded}>
        <Markdown html={source.markdown_source} noMargin />
        <FromBlock>
          Defined in
          <Link href={gitURL(source)} text={`${cleanFilePath(source)}, ${lineInfo}`} />
        </FromBlock>
      </SourceCode>
    </>
  );
};

export const MethodList = ({ title, list, id }) => (
  list && list.length > 0
  && (
  <SectionContainer id={id}>
    <Heading>{title}</Heading>
    {list.sort((a, b) => a.name.localeCompare(b.name)).map((i) => (
      <Margin id={i.name} key={i.name} bottom={23}>
        <Method {...i} type={null} />
        <Margin top={5}>
          <DocumentationBlock doc={i.doc} />
        </Margin>
        <Margin top={13}>
          <SourceBlock source={i.defined_by} />
        </Margin>
      </Margin>
    ))}
  </SectionContainer>
  )
);

export const FieldBlock = ({ list }) => (
  <FieldList>
    <h3>Arguments</h3>
    <table>
      <tbody>
        {Object
          .keys(list)
          .map((k) => ({ name: k, contents: list[k] }))
          .map((i) => (
            <tr key={i.name}>
              <td className="field-name">{i.name}</td>
              <td className="field-contents">
                <TextBlock list={i.contents.contents} />
              </td>
            </tr>
          ))}
      </tbody>
    </table>
  </FieldList>
);

export const Reference = (ref) => {
  if (!ref.ref_path) {
    return <Unresolved obj={ref} />;
  }

  let path = [];
  if (ref.ref_type === 'method') {
    // This one requires an extra step...
    const components = [...ref.ref_path];
    const methodName = components.pop();
    const parentName = components.pop();
    path = [...components, `${parentName}#${methodName}`];
  } else {
    path = ['/components', ...ref.ref_path].join('/');
  }

  return (
    <NextLink href={path.join('/')}>
      <BaseReference type={ref.ref_type}>
        {ref.contents}
      </BaseReference>
    </NextLink>
  );
};

export const TextBlock = ({ list }) => {
  if (!list.map) {
    list = [{ type: 'html', contents: list }];
  }

  const TextElement = ({ element, kind }) => {
    switch (kind) {
      case 'span':
        return <Markdown noMargin inline html={element.contents} />;
      case 'ref':
        return <Reference {...element} />;
      case 'html':
        return <Markdown html={element.contents} />;
      case 'sym_ref':
        return <Symbol>{element.contents}</Symbol>;
      default:
        return (
          <>
            Unknown textblock item
            {kind}
            {' '}
            {JSON.stringify(i, undefined, 4)}
          </>
        );
    }
  };
  return (
    <ElementContainer>
      {list.map((i, idx) => (
        <React.Fragment key={idx}>
          <TextElement element={i} kind={i.type} />
        </React.Fragment>
      ))}
    </ElementContainer>
  );
};

export const DocumentationBlock = ({ doc, noMargin, id }) => {
  if (!doc) {
    return <Faded>(No documentation available)</Faded>;
  }
  if (!doc.contents.sort) {
    doc = { contents: [doc] };
  }
  return (
    <div id={id}>
      {doc && doc.contents.map((i, idx) => {
        switch (i.type) {
          case 'text_block':
            return <TextBlock key={idx} list={i.contents} />;
          case 'code_example':
            return <Markdown key={idx} noMargin={noMargin} html={i.contents} />;
          case 'field_block':
            return <FieldBlock key={idx} list={i.contents} />;
          default:
            return (
              <Text key={idx}>
                !Unexpected item
                {i.type}
              </Text>
            );
        }
      })}
    </div>
  );
};
