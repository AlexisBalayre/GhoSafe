import React from "react";
import router from "next/router";

export const WrongChainModal = ({
  goodChain
}: {
  goodChain: string;
}
) => {
  return (
    <div>
      <dialog id="wrong_chain" className="modal">
        <div className="modal-box">
          <h3 className="font-bold text-lg text-center">Wrong Chain 🙁</h3>
          <p className="py-4">
            Please switch to {goodChain} to use this feature.
          </p>
        </div>
        <form method="dialog" className="modal-backdrop">
          <button onClick={() => router.push(`/`)}>close</button>
        </form>
      </dialog>
    </div>
  );
};
