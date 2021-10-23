import styled from "styled-components";
import { mono } from "@/styles/fonts";

export const Linked = styled.div`
  border-bottom: dashed 1px white;
  padding-bottom: 3px;
  cursor: pointer;
`;

export const Container = styled.span`
  display: flex;
  flex-wrap: wrap;
  align-items: center;

  .decoration {
    margin-right: 8px;
    margin-left: -20px;
  }
`;

export const TypeDef = styled.span`
  ${mono({ weight: 500 })};
  color: #808080;
  margin-right: 11px;
  text-transform: capitalize;
`;
