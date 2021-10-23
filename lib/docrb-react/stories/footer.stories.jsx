import React from 'react';

import { Footer } from "@/components/footer";

export default {
  title: 'Basic/Footer',
  component: Footer,
};

export const Basic = (args) => <Footer {...args} />;
Basic.args = {
  updatedAt: "someDate",
  version: "0.0.0.dev"
}
