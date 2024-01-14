import { blo } from "blo";
import { Types } from "connectkit";

export const MyCustomAvatar = ({ address, ensImage, size }: Types.CustomAvatarProps) => {
  return (
    <img
      className="rounded-full"
      src={ensImage || blo(address as `0x${string}`)}
      width={size}
      height={size}
      alt={`${address} avatar`}
    />
  );
};
