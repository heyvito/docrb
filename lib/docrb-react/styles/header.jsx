import styled, { css } from 'styled-components';
import { body } from "@/styles/fonts";

export const Base = styled.div`
  padding-left: 52px;
  padding-right: 40px;
  background-color: #101010;
  min-height: 240px;
  display: flex;
  justify-content: space-between;
`;

export const Project = styled.div`
  ${body};
  color: #FFFFFF;

  h1 {
    font-size: 64px;
    font-weight: 300;
    margin: 64px 0 0;
    padding: 0;
  }

  h3 {
    font-size: 16px;
    font-weight: 400;
    margin: 8px 0 0;
    padding: 0;
  }
`

export const Class = styled.div`
  margin-top: 46px;
`;

export const RightSide = styled.div`
  display: flex;
  align-items: center;
  flex-direction: column;
`

export const LinkPanel = styled.div`
  display: flex;
  flex-direction: column;
  align-items: end;
`;

export const LinkRow = styled.div`
  display: flex;
  margin-bottom: 6px;
`;

const mono = css`
  font-family: 'IBM Plex Mono', monospace;
  font-size: 16px;
`;

export const Type = styled.h3`
  ${mono};
  color: white;
`;

export const Defs = styled.div`
  ${body({ weight: 300 })};
  color: white;
  margin-left: 6px;
`;

export const ClassName = styled.h1`
  ${body({ weight: 300 })};
  font-size: 64px;
  color: #FFFFFF;
`;

export const DefLink = styled.span`
  a {
    ${mono};
  }
`;

export const ChevronContainer = styled.div`
  svg {
    margin-right: 8px;
    rotation: ${(props) => props.collapsed ? 0 : 180}deg;
    rotate: ${(props) => props.collapsed ? 0 : 180}deg;
  }

  ${body({ weight: 500 })};
  color: #FFFFFF;
  display: flex;
  margin-top: 18px;
  margin-left: 10px;
  cursor: pointer;
`;

export const Toggles = styled.div`
  display: ${(props) => props.collapsed ? "none" : "flex"};
  flex-direction: row;
  margin: 22px 10px 30px;
`;

export const Column = styled.div`
  margin-right: 50px;
  display: flex;
  flex-direction: column;
  row-gap: 8px;
`;
