import {
  Argument,
  ArgumentsContainer,
  Colon,
  Equal,
  Label,
  MethodName, Number, Plain, Rest, String, Symbol
} from "@/styles/method";
import React from "react";
import { Container, TypeDef } from "@/styles/common";
import { Link } from "@/components/common";
import {Icon} from "@/components/icon";

const continuationForType = (type) => {
  if (!type) {
    return "";
  }
  if (type === "kwarg" || type === "kwoptarg") {
    return <Colon/>;
  } else if (type.indexOf("opt") === 0) {
    return <Equal/>;
  }
}

const valueForArgument = (value, valueType) => {
  if (!valueType) {
    return;
  }
  switch (valueType) {
    case "sym":
    case "bool":
      return <Symbol>{value}</Symbol>;
    case "nil":
      return <Symbol>nil</Symbol>;
    case "int":
      return <Number>{value}</Number>;
    case "str":
      return <String>{value}</String>;
    default:
      return <Plain>{value}</Plain>;
  }
}

const restArg = (type) => {
  if (type === "kwrestarg") {
    return <Rest double/>;
  } else if (type === "restarg") {
    return <Rest/>;
  }
}

const MethodArgument = ({ type, name, value, value_type }) => (
  <Argument>
    {restArg(type)}
    {name}
    {continuationForType(type)}
    {valueForArgument(value, value_type)}
  </Argument>
)

export const Method = ({ visibility, type, name, href, args, doc, decoration }) => {
  const base = (
    <Container>
      <MethodName>{name}</MethodName>
      {args && <ArgumentsContainer empty={args.length === 0}>
        {args.map(arg => (
          <MethodArgument key={arg.name} {...arg} />
        ))}
      </ArgumentsContainer>}
    </Container>
  );

  return (
    <Container>
      {decoration && <Icon className="decoration"
                           name={decoration}
                           size={12}
                           title={decoration === "inherited"
                             ? "Inherited"
                             : "Override"}
                      />}
      {type && <TypeDef>{type}</TypeDef>}
      {href
        ? <Link href={href}>{base}</Link>
        : base}
      {visibility && (
        visibility.toLowerCase() !== "public"
          ? <Label>{visibility}</Label>
          : (doc && doc.doc_visibility_annotation && doc.doc_visibility_annotation !== 'public' && <Label>{doc.doc_visibility_annotation}</Label>)
      )}
    </Container>
  )
}
