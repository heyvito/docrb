import { ReactComponent as Balance } from '@/images/balance.svg';
import { ReactComponent as GitHub } from '@/images/github.svg';
import { ReactComponent as RubyGems } from '@/images/rubygems.svg';
import { ReactComponent as User } from '@/images/user.svg';
import { ReactComponent as Home } from '@/images/home.svg';
import { ReactComponent as Chevron } from '@/images/chevron.svg';
import { ReactComponent as CheckboxOn } from '@/images/checkbox-on.svg';
import { ReactComponent as CheckboxOff } from '@/images/checkbox-off.svg';
import { ReactComponent as Override } from '@/images/override.svg';
import { ReactComponent as Inherited } from '@/images/inherited.svg';
import { ReactComponent as QuestionMark } from '@/images/questionmark.svg';

import { IconBase } from '@/styles/icon';

const byName = {
  balance: <Balance />,
  github: <GitHub />,
  rubygems: <RubyGems />,
  user: <User />,
  home: <Home />,
  chevron: <Chevron />,
  checkboxOn: <CheckboxOn />,
  checkboxOff: <CheckboxOff />,
  inherited: <Inherited />,
  override: <Override />,
  questionmark: <QuestionMark />,
};

export const iconNames = Object.keys(byName);

export const Icon = ({
  name, size, className, title,
}) => (
  <IconBase className={className} side={size} title={title}>
    {byName[name]}
  </IconBase>
);
