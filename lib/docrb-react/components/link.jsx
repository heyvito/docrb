import NextLink from 'next/link';
import { DottedLink, DashedLink } from '@/styles/link';

export const Link = ({ text, href, kind }) => {
  const inner = kind === 'dotted'
    ? <DottedLink>{text}</DottedLink>
    : <DashedLink>{text}</DashedLink>;
  return href.indexOf('http') === 0
    ? <DashedLink href={href} rel="noreferrer" target="_blank">{text}</DashedLink>
    : <NextLink href={href}>{inner}</NextLink>;
};
