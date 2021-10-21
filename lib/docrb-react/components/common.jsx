import { Linked } from "@/styles/common";
import NextLink from "next/link";
import React from "react";

export const Link = ({ href, children }) => (
  <Linked className="linked-container">
    <NextLink href={href}>
      {children}
    </NextLink>
  </Linked>
);
