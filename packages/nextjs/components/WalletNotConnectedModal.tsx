import React from "react";
import router from "next/router";

export const WalletNotConnectedModal = () => {
  return (
    <div>
      <dialog id="wallet_not_connected" className="modal">
        <div className="modal-box">
          <h3 className="font-bold text-lg text-center">No Connected Wallet! 🙁</h3>
          <p className="py-4">
            Please connect a wallet by clicking on &#34;Connect Wallet&#34; in the top right-hand corner.
          </p>
        </div>
        <form method="dialog" className="modal-backdrop">
          <button onClick={() => router.push(`/`)}>close</button>
        </form>
      </dialog>
    </div>
  );
};
