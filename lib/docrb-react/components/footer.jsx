import {BaseFooter, Left, Right} from "@/styles/footer";
import {Link} from "@/components/link";

export const Footer = ({ updatedAt, version }) => (
  <BaseFooter>
    <Left>
      Last Updated {updatedAt}
    </Left>
    <Right>
      Generated by <Link href="https://github.com/heyvito/docrb" text="Docrb" /> version {version}
    </Right>
  </BaseFooter>
)
