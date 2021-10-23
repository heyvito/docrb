import { Base, TabBase } from '@/styles/tab-bar';

const Tab = ({ selected, text, onClick }) => <TabBase onClick={onClick} selected={selected}>{text}</TabBase>;

export const TabBar = ({ items, selectedIndex, onWantsSelectionChange }) => (
  <Base>
    {items.map((i, idx) => (
      <Tab
        key={idx}
        onClick={() => onWantsSelectionChange && onWantsSelectionChange(idx)}
        selected={idx === selectedIndex}
        text={i}
      />
    ))}
  </Base>
);
