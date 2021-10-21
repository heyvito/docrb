import styled, { css } from "styled-components";
import { body, mono } from "@/styles/fonts";

export const MethodName = styled.span`
  ${mono};
  color: #39B6B5;
`;

export const ArgumentsContainer = styled.span`
  ${mono};
  color: #39B6B5;
  display: flex;
  ${props => !props.empty && `
    :before {
      content: '(';
    }

    :after {
      content: ')';
    }
  `}
`

export const Argument = styled.span`
  color: #FFAB42;

  :not(:first-of-type) {
    margin-left: 8px;
  }

  :not(:last-of-type) {
    :after {
      content: ',';
      color: #A5ACBA;
    }
  }
`;

const baseArgVal = css`
  margin-left: 8px;
`;

export const Symbol = styled.span`
  ${baseArgVal};
  color: #CF91C9;
`;

export const String = styled.span`
  ${baseArgVal};
  color: #8CC98F;

  :before, :after {
    content: '"';
    color: #39B6B5;
  }
`;

export const Number = styled.span`
  ${baseArgVal};
`;

export const Equal = styled.span`
  ${baseArgVal};
  color: #FF724C;

  :after {
    content: "=";
  }
`;


export const Plain = styled.span`
  ${baseArgVal};
  color: #FFF;
`;

export const Colon = styled.span`
  color: #A5ACBA;

  :after {
    content: ':';
  }
`;

export const Rest = styled.span`
  color: #A5ACBA;

  :after {
    content: "${(props) => props.double ? "**" : "*"}";
  }
`;

export const Label = styled.span`
  background-color: #29292B;
  border-radius: 3px;
  padding: 3px 6px;
  ${body({ weight: 500, size: 11 })};
  color: #A7A7A7;
  letter-spacing: 0.79px;
  text-align: center;
  text-transform: uppercase;
  margin-left: 8px;
`;
