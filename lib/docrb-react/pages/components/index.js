import { useRouter } from 'next/router';
import Head from 'next/head';
import { docOutline, projectHeader } from '@/lib/index';

import { TabBar } from '@/components/tab-bar';
import { ProjectHeader } from '@/components/project-header';
import { ComponentList } from '@/components/component-listing';

const ComponentsPage = () => {
  const router = useRouter();
  return (
    <>
      <Head>
        <title>
          Components -
          {projectHeader.name}
          {' '}
          - Docrb
        </title>
      </Head>
      <ProjectHeader {...projectHeader} />
      <TabBar
        items={['Readme', 'Components']}
        selectedIndex={1}
        onWantsSelectionChange={(idx) => {
          if (idx !== 0) {
            return;
          }
          router.push('/');
        }}
      />
      <ComponentList list={docOutline} />
    </>
  );
};

export default ComponentsPage;
