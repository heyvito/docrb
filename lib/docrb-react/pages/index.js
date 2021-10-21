import styled from 'styled-components';
import { useRouter } from 'next/router'

import { TabBar } from '@/components/tab-bar';
import { Markdown } from "@/components/markdown";
import { ProjectHeader } from '@/components/project-header';
import markdownContent from "../.docrb/readme.html";
import { projectHeader } from "@/lib/index";

const Home = () => {
  const router = useRouter();
  return <>
    <ProjectHeader {...projectHeader} />
    <TabBar items={["Readme", "Components"]}
            selectedIndex={0}
            onWantsSelectionChange={(idx) => {
              if (idx !== 1) {
                return;
              }
              router.push("/components");
            }} />
    <Markdown html={markdownContent} />
  </>;
};

export default Home;
