import styled from 'styled-components';
import { HighlightDefinitions } from "@/styles/markdown";
import { body, mono } from "@/styles/fonts";

export const MainContainer = styled.div`
  margin: 44px 46px;
  display: flex;
  flex-wrap: wrap;
  flex-direction: row;
  column-gap: 38px;
`;

export const Left = styled.div`
  flex: 1;
  max-width: 100%;
  flex-wrap: wrap;
`;

export const Right = styled.div`
  padding-right: 54px;

  .linked-container {
    margin-bottom: 5px;
    display: inline-block;
  }

  a {
    color: #FFF;
    ${body};
    text-decoration: none;
  }
`;

export const BaseText = styled.span`
  ${body};
  color: #FFFFFF;
`;

export const BaseHeading = styled.div`
  ${body({ size: 24 })};
  color: #FFFFFF;
  padding-bottom: 12px;
`;

export const BaseLinkColumn = styled.div`
  display: flex;
  flex-direction: column;
  row-gap: 8px;
  padding-left: 12px;
`;

export const BaseHorizontalContainer = styled.div`
  display: flex;
  column-gap: 50px;
`;

export const BaseHTMLContent = styled.div`
  ${body};
  color: #FFFFFF;
  margin-bottom: ${props => props.noMargin ? 0 : 12}px;
  display: ${props => props.inline ? "inline" : "block"};

  p code {
    ${mono};
    font-size: 95%;
    padding: 3px 4px;
    background-color: #29292B;
    border-radius: 3px;
  }

  ${HighlightDefinitions};
`;

export const Faded = styled.div`
  ${body};
  color: #707070;
  margin-top: 5px;
`;

export const Mono = styled.span`
  ${mono};
  color: #FFFFFF;
`;

export const AttributeContainer = styled.div`
  margin-bottom: 12px;

  .decoration {
    display: inline-block;
    margin-right: 8px;
    margin-left: -18px;
  }
`;

export const SectionContainer = styled.div`
  margin: 25px 0 0;
`;

export const ToggleWrapper = styled.div`
  text-align: right;
  margin: 13px 0 22px 0;
`;

export const SourceLink = styled.span`
  ${body({ weight: 500 })};
  border-bottom: white 1px dotted;
  cursor: pointer;
  color: #FFF;
`;

export const SourceCode = styled.div`
  display: ${props => props.expanded ? "block" : "none"};
`;

export const FieldList = styled.div`
  h3 {
    ${body({ weight: 500, size: 11 })};
    color: #A7A7A7;
    letter-spacing: 0.79px;
    text-transform: uppercase;
    margin-top: 24px;
  }

  table {
    margin-bottom: 24px;
  }

  td {
    padding-top: 5px;
  }

  .field-name {
    ${mono};
    color: white;
    text-align: right;
    vertical-align: top;
    padding-right: 20px;
  }
`;

const colorForReference = ({ type }) => {
  switch (type) {
    case "class":
      return "#FFAB42";
    case "module":
      return "#579AD1"
    default:
      return "white";
  }
}

export const BaseReference = styled.span`
  ${mono({ weight: 300, size: 15 })};
  color: ${colorForReference};
  border-bottom: 1px dashed ${colorForReference};
  cursor: pointer;
`;

export const BaseUnresolved = styled.div`
  border: 1px dotted #D8D8D8;
  border-radius: 10px 3px 3px 10px;
  display: inline-flex;
  color: white;
  justify-content: center;
  align-content: center;
  align-items: center;

  .icon {
    margin-left: 2px;
    margin-right: 2px;
  }

  span {
    ${mono({ size: 15 })};
  }
`

export const FromBlock = styled.div`
  ${body};
  font-size: 80%;
  color: white;
  a {
    font-size: inherit;
  }
`;

export const Symbol = styled.span`
  ${mono};
  color: #CF91C9;
`;
