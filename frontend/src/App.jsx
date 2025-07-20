import { useState } from "react";
import { ethers } from "ethers";
import contractABI from "./ArtistEditionNFTABI.json";

const CONTRACT_ADDRESS = "0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0";

function App() {
  // Register Artist
  const [artistAddress, setArtistAddress] = useState("");
  const [registerArtistStatus, setRegisterArtistStatus] = useState("");

  // Register Production Partner (Fabricator)
  const [partnerAddress, setPartnerAddress] = useState("");
  const [registerPartnerStatus, setRegisterPartnerStatus] = useState("");

  // Register Operator
  const [operatorAddress, setOperatorAddress] = useState("");
  const [registerOperatorStatus, setRegisterOperatorStatus] = useState("");

  // Register Edition & Financials
  const [editionForm, setEditionForm] = useState({
    parentEditionID: "",
    operator: "",
    artist: "",
    productionPartner: "",
    salePrice: "",
    editionSize: "",
    productionCost: "",
    artistShare: 34,
    productionPartnerShare: 33,
    operatorShare: 33,
    artworkURI: ""
  });
  const [registerEditionStatus, setRegisterEditionStatus] = useState("");

  // File upload state
  const [selectedFile, setSelectedFile] = useState(null);

  // Function to enforce the total at 100%
  function handleSliderChange(name, value) {
    value = Number(value);
    let { artistShare, productionPartnerShare, operatorShare } = editionForm;

    if (name === "artistShare") artistShare = value;
    if (name === "productionPartnerShare") productionPartnerShare = value;
    if (name === "operatorShare") operatorShare = value;

    const total = artistShare + productionPartnerShare + operatorShare;
    // If total > 100, reduce the value that was just changed
    if (total > 100) {
      const overflow = total - 100;
      if (name === "artistShare") artistShare -= overflow;
      if (name === "productionPartnerShare") productionPartnerShare -= overflow;
      if (name === "operatorShare") operatorShare -= overflow;
    }
    setEditionForm(f => ({
      ...f,
      artistShare,
      productionPartnerShare,
      operatorShare
    }));
  }

  // Register Artist Handler
  async function registerArtist() {
    setRegisterArtistStatus("Artist registered! (UI only)");
  }

  // Register Production Partner Handler
  async function registerProductionPartner() {
    setRegisterPartnerStatus("Production partner registered! (UI only)");
  }

  // Register Operator Handler
  async function registerOperator() {
    setRegisterOperatorStatus("Operator registered! (UI only)");
  }

  // Register Edition and Set Financials Handler
  async function registerEdition(e) {
    e.preventDefault();
    setRegisterEditionStatus("Registering edition...");
    try {
      // Here you would call your contract as before, if desired
      setRegisterEditionStatus("Edition registered! (UI only)");

      // Optional: handle selected file (not uploaded anywhere in this demo)
      if (selectedFile) {
        alert("File chosen (not uploaded in this demo): " + selectedFile.name);
      }
    } catch (err) {
      setRegisterEditionStatus("Error: " + err.message);
    }
  }

  return (
    <div style={{ padding: 24, fontFamily: "sans-serif" }}>
      <h1 style={{ fontWeight: "bold", marginBottom: 32 }}>coldstart</h1>
      <p style={{ marginBottom: 32, maxWidth: 540 }}>
        Instructions for Using Coldstart
• Fill out all required details to create a new edition.
• Editions can then be minted and managed on-chain.
• No coding experience needed-just enter info and submit!
      </p>

      {/* Register Artist */}
      <h2>Register Artist</h2>
      <input
        type="text"
        value={artistAddress}
        onChange={e => setArtistAddress(e.target.value)}
        placeholder="Artist Wallet Address"
        style={{ marginRight: 8, padding: 4 }}
      />
      <button onClick={registerArtist} style={{ padding: "4px 12px" }}>
        Register
      </button>
      <div style={{ marginTop: 12, marginBottom: 32 }}>{registerArtistStatus}</div>

      {/* Register Production Partner */}
      <h2>Register Production Partner</h2>
      <input
        type="text"
        value={partnerAddress}
        onChange={e => setPartnerAddress(e.target.value)}
        placeholder="Production Partner Wallet"
        style={{ marginRight: 8, padding: 4 }}
      />
      <button onClick={registerProductionPartner} style={{ padding: "4px 12px" }}>
        Register
      </button>
      <div style={{ marginTop: 12, marginBottom: 32 }}>{registerPartnerStatus}</div>

      {/* Register Operator */}
      <h2>Register Operator</h2>
      <input
        type="text"
        value={operatorAddress}
        onChange={e => setOperatorAddress(e.target.value)}
        placeholder="Operator Wallet Address"
        style={{ marginRight: 8, padding: 4 }}
      />
      <button onClick={registerOperator} style={{ padding: "4px 12px" }}>
        Register
      </button>
      <div style={{ marginTop: 12, marginBottom: 32 }}>{registerOperatorStatus}</div>

      {/* Register Edition */}
      <h2>Register Edition</h2>
      <form onSubmit={registerEdition}>
        <div style={{ display: "flex", flexDirection: "column", gap: 14, maxWidth: 350 }}>
          <input
            type="number"
            placeholder="Parent Edition ID"
            value={editionForm.parentEditionID}
            onChange={e => setEditionForm(f => ({ ...f, parentEditionID: e.target.value }))}
          />
          <input
            type="text"
            placeholder="Operator Address"
            value={editionForm.operator}
            onChange={e => setEditionForm(f => ({ ...f, operator: e.target.value }))}
          />
          <input
            type="text"
            placeholder="Artist Address"
            value={editionForm.artist}
            onChange={e => setEditionForm(f => ({ ...f, artist: e.target.value }))}
          />
          <input
            type="text"
            placeholder="Production Partner Address"
            value={editionForm.productionPartner}
            onChange={e => setEditionForm(f => ({ ...f, productionPartner: e.target.value }))}
          />
          <input
            type="number"
            placeholder="Sale Price"
            value={editionForm.salePrice}
            onChange={e => setEditionForm(f => ({ ...f, salePrice: e.target.value }))}
          />
          <input
            type="number"
            placeholder="Edition Size"
            value={editionForm.editionSize}
            onChange={e => setEditionForm(f => ({ ...f, editionSize: e.target.value }))}
          />
          <input
            type="number"
            placeholder="Production Cost"
            value={editionForm.productionCost}
            onChange={e => setEditionForm(f => ({ ...f, productionCost: e.target.value }))}
          />
          <input
            type="text"
            placeholder="Artwork URI"
            value={editionForm.artworkURI}
            onChange={e => setEditionForm(f => ({ ...f, artworkURI: e.target.value }))}
          />

          {/* Sliders */}
          <div style={{ marginTop: 10 }}>
            <label>
              Artist Share: {editionForm.artistShare}%
              <input
                type="range"
                min={0}
                max={100}
                value={editionForm.artistShare}
                onChange={e => handleSliderChange("artistShare", e.target.value)}
                style={{ width: "100%" }}
              />
            </label>
            <label>
              Production Partner Share: {editionForm.productionPartnerShare}%
              <input
                type="range"
                min={0}
                max={100}
                value={editionForm.productionPartnerShare}
                onChange={e => handleSliderChange("productionPartnerShare", e.target.value)}
                style={{ width: "100%" }}
              />
            </label>
            <label>
              Operator Share: {editionForm.operatorShare}%
              <input
                type="range"
                min={0}
                max={100}
                value={editionForm.operatorShare}
                onChange={e => handleSliderChange("operatorShare", e.target.value)}
                style={{ width: "100%" }}
              />
            </label>
            <div style={{ fontSize: 12, color: "#888", marginTop: 4 }}>
              Total: {editionForm.artistShare + editionForm.productionPartnerShare + editionForm.operatorShare}%
              {editionForm.artistShare + editionForm.productionPartnerShare + editionForm.operatorShare !== 100 && (
                <span style={{ color: "red" }}> (Must total 100%)</span>
              )}
            </div>
          </div>

          {/* File upload section */}
          <div style={{ marginTop: 16 }}>
            <label>
              Attach Artwork:{" "}
              <input
                type="file"
                onChange={e => {
                  setSelectedFile(e.target.files[0]);
                }}
              />
            </label>
            {selectedFile && (
              <div style={{ fontSize: 13, marginTop: 4 }}>
                Selected file: {selectedFile.name}
              </div>
            )}
          </div>

          <button
            type="submit"
            style={{ padding: "4px 12px" }}
            disabled={
              editionForm.artistShare +
                editionForm.productionPartnerShare +
                editionForm.operatorShare !==
              100
            }
          >
            Create Smart Contract
          </button>
        </div>
      </form>
      <div style={{ marginTop: 12 }}>{registerEditionStatus}</div>
    </div>
  );
}

export default App;
