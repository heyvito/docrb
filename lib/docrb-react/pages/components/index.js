import styled from 'styled-components';
import { useRouter } from 'next/router'

import { TabBar } from '@/components/tab-bar';
import { ProjectHeader } from '@/components/project-header';
import { ComponentList } from '@/components/component-listing';

import { docOutline, projectHeader } from '@/lib/index';


const Home = () => {
  const router = useRouter();
  return <>
    <ProjectHeader {...projectHeader} />
    <TabBar items={["Readme", "Components"]}
            selectedIndex={1}
            onWantsSelectionChange={(idx) => {
              if (idx !== 0) {
                return;
              }
              router.push("/");
            }} />
    <ComponentList list={docOutline} />
  </>;
};

export default Home;
