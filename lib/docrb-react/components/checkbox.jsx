import React from 'react';
import { Container, Label } from '@/styles/checkbox';
import { Icon } from "@/components/icon";

export const Checkbox = ({label, checked = false, onChange = () => {}}) => {
  return (
    <Container onClick={() => onChange(!checked)}>
      <Icon name={checked ? "checkboxOn" : "checkboxOff"} />
      <Label>{ label }</Label>
    </Container>
  );
}
