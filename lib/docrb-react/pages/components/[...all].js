import { useEffect, useState } from 'react';
import Head from 'next/head';
import {
  getDocFor,
  generateAllDocPaths,
  projectHeader,
  definitionsFor,
  specializedProjection,
} from '@/lib/index';

import { ClassHeader } from '@/components/class-header';
import { Breadcrumb } from '@/components/breadcrumb';
import {
  ClassDetails, AttributeList, MethodList, DocumentationBlock, Heading,
} from '@/components/documentation';
import { Left, MainContainer, Right } from '@/styles/documentation';
import { Link } from '@/components/common';

export async function getStaticPaths() {
  return {
    paths: generateAllDocPaths(),
    fallback: false,
  };
}

export async function getStaticProps(context) {
  const path = [...context.params.all];
  const item = getDocFor([...path]);
  if (!item) {
    return { notFound: true };
  }

  return {
    props: {
      item,
      path: [...path],
    },
  };
}

const withDoc = (fn) => (i) => {
  if (!i.doc) {
    return true;
  }
  if (!i.doc.doc_visibility_annotation) {
    return true;
  }

  return fn(i);
};

const filtering = (list, filters) => {
  const filtersToApply = [];
  if (filters.hideInternal) {
    filtersToApply.push(withDoc((i) => i.doc.doc_visibility_annotation.toLowerCase() !== 'internal'));
  }

  if (filters.hidePrivate) {
    filtersToApply.push((i) => i.visibility !== 'private');
  }

  if (!filters.showInherited) {
    filtersToApply.push((i) => i.origin !== 'inheritance');
  }

  if (!filters.showExtended) {
    filtersToApply.push((i) => i.origin !== 'extension');
  }

  if (!filters.showIncluded) {
    filtersToApply.push((i) => i.origin !== 'inclusion');
  }

  if (filters.hideAttributes) {
    filtersToApply.push((i) => i.type !== 'Attribute');
  }

  let newList = [...list];
  for (const fn of filtersToApply) {
    newList = newList.filter(fn);
  }

  return newList;
};

const Component = ({ item, path }) => {
  const parents = [];
  const breadcrumbItems = path.map((i) => {
    const result = { name: i, parents: [...parents] };
    parents.push(i);
    return result;
  });
  item = specializedProjection.findPath(path);

  const [filters, setFilters] = useState({});
  const [defs, setDefs] = useState(item.defs || []);
  const [sdefs, setSdefs] = useState(item.sdefs || []);
  const [attributes, setAttributes] = useState(item.attributes || []);
  const hasClassDocumentation = !!item.doc;
  const hasClassDetails = item.inherits
      || (item.extends && item.extends.length > 0)
      || (item.includes && item.includes.length > 0)
      || (item.modules && item.modules.length > 0)
      || (item.classes && item.classes.length > 0);
  const hasAttributes = attributes.length > 0;
  const hasClassMethods = sdefs.length > 0;
  const hasInstanceMethods = defs.length > 0;

  useEffect(() => {
    setDefs(filtering(item.defs || [], filters));
    setSdefs(filtering(item.sdefs || [], filters));
    setAttributes(filtering(item.attributes || [], filters));
  }, [filters, item.attributes, item.defs, item.sdefs]);

  return (
    <>
      <Head>
        <title>
          {item.name}
          {' '}
          -
          {' '}
          {projectHeader.name}
          {' '}
          - Docrb
        </title>
      </Head>
      <ClassHeader
        type={item.type}
        name={item.name}
        definitions={definitionsFor(item)}
        onChangeFilter={(filters) => setFilters(filters)}
      />
      <Breadcrumb projectName={projectHeader.name} items={breadcrumbItems} />
      <MainContainer>
        <Left>
          {hasClassDocumentation && <DocumentationBlock id="class-documentation" doc={item.doc} />}
          {hasClassDetails && <ClassDetails id="class-details" item={item} />}
          {hasAttributes && <AttributeList id="attributes" list={attributes} />}
          {hasClassMethods && <MethodList id="class-methods" title="Class Methods" list={sdefs} />}
          {hasInstanceMethods && <MethodList id="instance-methods" title="Instance Methods" list={defs} />}
        </Left>
        <Right>
          <Heading>In this Page</Heading>
          {hasClassDocumentation && <div><Link href="#class-documentation">Class Documentation</Link></div>}
          {hasClassDetails && <div><Link href="#class-details">Inheritance</Link></div>}
          {hasAttributes && <div><Link href="#attributes">Attributes</Link></div>}
          {hasClassMethods && <div><Link href="#class-methods">Class Methods</Link></div>}
          {hasInstanceMethods && <div><Link href="#instance-methods">Instance Methods</Link></div>}
        </Right>
      </MainContainer>
    </>
  );
};

export default Component;
