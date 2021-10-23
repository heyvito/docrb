import { useRouter } from 'next/router'
import Head from 'next/head';
import { projectHeader } from "@/lib/index";

import { TabBar } from '@/components/tab-bar';
import { Markdown } from "@/components/markdown";
import { ProjectHeader } from '@/components/project-header';
import markdownContent from "../.docrb/readme.html";

const Home = () => {
  const router = useRouter();
  return <>
    <Head>
      <title>{projectHeader.name} - Docrb</title>
    </Head>
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
