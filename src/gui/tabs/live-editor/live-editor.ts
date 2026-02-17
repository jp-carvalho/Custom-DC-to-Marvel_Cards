import * as PIXI from "pixi.js";
import { Card, CARD_MAX_HEIGHT, CARD_MAX_WIDTH } from "src/cards/card/";
import { EditableTable, IRowData, IRowValues } from "src/gui/table";
import { Tab } from "src/gui/tabular/";
import { clone, select, template } from "src/utils/";
import * as store from "store";
import { cardsHeadings, cardsRows, defaultsHeadings, defaultsRows, setsData } from "./live-editor-tables";
import * as hbs from "./live-editor.hbs";
import "./live-editor.scss";

const tabTemplate = template(hbs as any);

/** Map for EN to PT card types */
const typeTranslations: {[key: string]: string} = {
    "Hero": "Herói",
    "Villain": "Vilão",
    "Equipment": "Equipamento",
    "Location": "Localização",
    "Starter": "Inicial",
    "Super Power": "Superpoder",
    "Weakness": "Fraqueza",
    "Villain Nemesis": "Vilão Nêmesis",
};

/** Map for EN to PT subtypes */
const subtypeTranslations: {[key: string]: string} = {
    "test": "teste",
};

/** The Live Editor tab of a Tabular */
export class LiveEditorTab extends Tab {
    /** The container element for all rendered card canvases */
    private canvasesElement: HTMLElement;

    /** The scale slider element */
    private scaleSlider: HTMLInputElement;

    /** The scale slider percent text element */
    private scaleSliderPercent: HTMLElement;

    /** The add row button element */
    private addRowButton: HTMLButtonElement;

    /** The reset to defaults button element */
    private resetToDefaultsButton: HTMLButtonElement;

    /** The defaults EditableTable */
    private defaultsTable: EditableTable;

    /** The custom cards EditableTable */
    private cardsTable: EditableTable;

    /** The PIXI application that we use to render cards off screen */
    private app: PIXI.Application;

    /** The PIXI.Graphics we use to clear the canvas before a re-render */
    private clearGraphics: PIXI.Graphics;

    /** The maximum number of cards users can create before we stop them */
    private maxCustomCards: number = 6;

    /** The warning container for when there are too many cards */
    private tooManyCardsElement: HTMLElement;

    /**
     * Row to card mapping of all custom cards
     * As all cards as static when not changed we store the results in a canvas
     * outside of the PIXI instance, so we can manipulate them like regular DOM
     * elements
     */
    private cards = new Map<IRowData, Card>();

    /** Row to card's canvas of all custom cards */
    private canvases = new Map<IRowData, HTMLCanvasElement>();

    /** Creates a new instance of the LiveEditorTab */
    constructor() {
        super("Live Editor", tabTemplate() as HTMLElement);

        this.tooManyCardsElement = select(this.element, ".too-many-cards");
        this.canvasesElement = select(this.element, ".canvases");
        this.addRowButton = select(this.element, ".add-row-button") as HTMLButtonElement;

        this.scaleSlider = select(this.element, ".canvases-scale-slider") as HTMLInputElement;
        this.scaleSlider.addEventListener("input", () => this.resizeCanvases());

        this.scaleSliderPercent = select(this.element, ".canvases-scale-percent");
        this.scaleSlider.value = store.get("card-scale") || 0.5;

        // Defaults Table \\
        this.defaultsTable = new EditableTable(select(this.element, ".defaults-table"));
        this.defaultsTable.addColumns(defaultsHeadings);

        this.defaultsTable.on(EditableTable.EventSymbols.rowAdded, (rowValues: IRowValues, row: IRowData) => {
            setTimeout(() => row.tr.classList.add("shown"), 50);
            setTimeout(() => this.addFileUploadToRow(row, "logoURL"), 100);
        });

        // if the defaults rows are edited, update all custom cards
        this.defaultsTable.on(EditableTable.EventSymbols.cellChanged, (row: IRowData): void => {
            // Check if Set changed to auto-update other fields
            const setEn = row.values.set;
            const setEntry = setsData.find((s) => s.original === setEn);

            if (setEntry) {
                // Update values
                row.values.setTextColor = setEntry.text;
                row.values.setBackgroundColor = setEntry.bg;

                // Update DOM inputs to reflect changes immediately
                const updateInput = (className: string, value: string) => {
                    const input = row.tr.querySelector(`.column-${className} input`) as HTMLInputElement;
                    if (input) { input.value = value; }
                };
                updateInput("setTextColor", setEntry.text);
                updateInput("setBackgroundColor", setEntry.bg);
            }

            this.updateStore(this.defaultsTable);
            this.renderAllCards();
        });

        this.defaultsTable.addRows(store.get("card-defaults") || defaultsRows);

        // Add "edit sets" button and modal functionality
        this.addSetEditor();
        this.injectModalStyles();

        // Custom Cards Table \\
        const cardsElement = select(this.element, ".cards-table");
        this.cardsTable = new EditableTable(cardsElement);

        this.cardsTable.on(EditableTable.EventSymbols.rowAdded, (rowValues: IRowValues, row: IRowData) => {
            this.updateStore(this.cardsTable);
            this.rowAdded(row);
            // Initialize variant options based on default type
            this.updateVariantOptions(row);
        });

        this.cardsTable.on(EditableTable.EventSymbols.cellChanged, (row: IRowData) => {
            // Logic to sync Cost and VP from English (1st) to Portuguese (2nd) card
            const rowIndex = this.cardsTable.rows.indexOf(row);
            if (rowIndex % 2 === 0) { // It's an English card (0, 2, 4...)
                const nextRow = this.cardsTable.rows[rowIndex + 1];
                if (nextRow) {
                    // Sync Cost
                    nextRow.values.cost = row.values.cost;
                    const costInput = nextRow.tr.querySelector(".column-cost input") as HTMLInputElement;
                    if (costInput) { costInput.value = String(row.values.cost); }

                    // Sync VP
                    let vpValue = row.values.victoryPoints;
                    if (String(vpValue).toLowerCase() === "you win") {
                        vpValue = "Você Venceu";
                    }
                    nextRow.values.victoryPoints = vpValue;
                    const vpInput = nextRow.tr.querySelector(".column-victoryPoints input") as HTMLInputElement;
                    if (vpInput) { vpInput.value = String(vpValue); }

                    // Sync and Translate Subtype
                    const englishSubtype = String(row.values.subtype);
                    const portugueseSubtype = subtypeTranslations[englishSubtype] || englishSubtype;

                    nextRow.values.subtype = portugueseSubtype;
                    const subtypeInput = nextRow.tr.querySelector(".column-subtype input") as HTMLInputElement;
                    if (subtypeInput) { subtypeInput.value = portugueseSubtype; }

                    // Sync Variant
                    nextRow.values.variant = row.values.variant;
                    const variantInput = nextRow.tr.querySelector(".column-variant select") as HTMLSelectElement;
                    if (variantInput) { variantInput.value = String(row.values.variant); }

                    // Sync Oversized
                    nextRow.values.oversized = row.values.oversized;
                    const oversizedInput = nextRow.tr.querySelector(".column-oversized input") as HTMLInputElement;
                    if (oversizedInput) { oversizedInput.checked = Boolean(row.values.oversized); }

                    // Sync and Translate Type
                    const englishType = String(row.values.type);
                    const portugueseType = typeTranslations[englishType];
                    if (portugueseType) {
                        nextRow.values.type = portugueseType;
                        const typeInput = nextRow.tr.querySelector(".column-type select") as HTMLSelectElement;
                        if (typeInput) {
                            // Ensure the Portuguese option exists in the dropdown for it to be selectable
                            let optionExists = false;
                            for (let i = 0; i < typeInput.options.length; i++) {
                                if (typeInput.options[i].value === portugueseType) {
                                    optionExists = true;
                                    break;
                                }
                            }
                            if (!optionExists) {
                                const option = document.createElement("option");
                                option.value = portugueseType;
                                option.text = portugueseType;
                                typeInput.add(option);
                            }
                            typeInput.value = portugueseType;

                            // Update variant options for the translated card since type changed
                            this.updateVariantOptions(nextRow);
                        }
                    }

                    this.renderCard(nextRow);
                }
            }

            // Update variant options for the current row (in case Type changed)
            this.updateVariantOptions(row);

            this.updateStore(this.cardsTable);
            this.renderCard(row);
        });

        this.cardsTable.on(EditableTable.EventSymbols.rowDeleted, (row: IRowData) => {
            this.updateStore(this.cardsTable);
            this.rowDeleted(row);
        });

        // Rendering related tasks \\
        this.app = new PIXI.Application(CARD_MAX_WIDTH, CARD_MAX_HEIGHT, {antialias: true, transparent: true});

        this.clearGraphics = new PIXI.Graphics();
        this.app.stage.addChild(this.clearGraphics);

        this.cardsTable.addColumns(cardsHeadings);
        this.cardsTable.addRows(store.get("cards") || cardsRows);

        this.addRowButton.addEventListener("click", () => {
            this.cardsTable.addRow(cardsRows[0]);
        });

        this.resetToDefaultsButton = select(this.element, ".reset-to-defaults") as HTMLButtonElement;
        this.resetToDefaultsButton.addEventListener("click", () => {
            this.resetToDefaults();
        });
    }

    private addSetEditor(): void {
        const setCell = this.defaultsTable.getRow(0).tr.querySelector(".column-name");
        if (!setCell) { return; }

        const pencilButton = document.createElement("button");
        pencilButton.innerHTML = "✏️";
        pencilButton.className = "edit-sets-button";
        pencilButton.type = "button"; // Prevent form submission if it's inside a form
        pencilButton.title = "Add a new set";

        // To avoid adding multiple buttons
        if (setCell.querySelector(".edit-sets-button")) {
            return;
        }

        setCell.innerHTML = "";
        setCell.appendChild(pencilButton);

        pencilButton.addEventListener("click", (e) => {
            e.stopPropagation();
            this.createSetEditorModal();
        });
    }

    private createSetEditorModal(): void {
        if (document.querySelector(".set-editor-modal")) {
            return;
        }

        const customSets = store.get("custom-sets") || [];
        let customSetsHtml = "";
        if (customSets.length > 0) {
            customSetsHtml = `
                <div class="custom-sets-container">
                    <h4>Manage Custom Sets</h4>
                    <ul class="custom-sets-list">
                        ${customSets.map((s: any) => `
                            <li data-original="${s.original}">
                                <span>${s.original}</span>
                                <button type="button" class="delete-set-btn" title="Delete">🗑️</button>
                            </li>
                        `).join("")}
                    </ul>
                </div>
            `;
        }

        const modal = document.createElement("div");
        modal.className = "set-editor-modal";
        modal.innerHTML = `
            <div class="modal-content">
                <h3>Add New Set</h3>
                <form>
                    <label>Set Name (for dropdown):</label>
                    <input type="text" name="original" required>

                    <label>English Display Name (for Card 1):</label>
                    <input type="text" name="en" required>

                    <label>Translated Name (for Card 2):</label>
                    <input type="text" name="pt" required>

                    <label>Set Text Color:</label>
                    <input type="color" name="text" value="#FFFFFF" required>

                    <label>Set Background Color:</label>
                    <input type="color" name="bg" value="#000000" required>

                    <div class="modal-buttons">
                        <button type="submit" class="save-button">Save</button>
                        <button type="button" class="cancel-button">Cancel</button>
                    </div>
                </form>
                ${customSetsHtml}
            </div>
        `;

        document.body.appendChild(modal);

        const form = modal.querySelector("form");
        const cancelButton = modal.querySelector(".cancel-button");
        const content = modal.querySelector(".modal-content");

        // Prevent clicks inside the modal from closing it
        content.addEventListener("click", (e) => e.stopPropagation());
        // Close modal on background click
        modal.addEventListener("click", () => document.body.removeChild(modal));

        // Handle Deletion
        const setsList = modal.querySelector(".custom-sets-list");
        if (setsList) {
            setsList.addEventListener("click", (e) => {
                const target = e.target as HTMLElement;
                if (target.classList.contains("delete-set-btn")) {
                    const li = target.closest("li");
                    const originalName = li.getAttribute("data-original");
                    if (confirm(`Delete set "${originalName}"?`)) {
                        this.deleteCustomSet(originalName);
                        li.remove();
                        if (setsList.children.length === 0) {
                            modal.querySelector(".custom-sets-container").remove();
                        }
                    }
                }
            });
        }

        form.addEventListener("submit", (e) => {
            e.preventDefault();
            const formData = new FormData(form);
            const newSet = {
                original: formData.get("original") as string,
                en: formData.get("en") as string,
                pt: formData.get("pt") as string,
                text: formData.get("text") as string,
                bg: formData.get("bg") as string,
            };

            // Save to localStorage
            const customSets = store.get("custom-sets") || [];
            customSets.push(newSet);
            store.set("custom-sets", customSets);

            // Update in-memory data
            setsData.push(newSet);

            // Update dropdown
            const setSelect = this.defaultsTable.getRow(0).tr.querySelector(".column-set select") as HTMLSelectElement;
            if (setSelect) {
                const option = document.createElement("option");
                option.value = newSet.original;
                option.text = newSet.original;
                setSelect.appendChild(option);
                setSelect.value = newSet.original;

                // Manually trigger change to update colors etc.
                const changeEvent = new Event("change", { bubbles: true });
                setSelect.dispatchEvent(changeEvent);
            }

            document.body.removeChild(modal);
        });

        cancelButton.addEventListener("click", () => {
            document.body.removeChild(modal);
        });
    }

    /**
     * Updates the variant dropdown options based on the card type
     */
    private updateVariantOptions(row: IRowData): void {
        const type = String(row.values.type);
        const variantSelect = row.tr.querySelector(".column-variant select") as HTMLSelectElement;

        if (!variantSelect) {
            return;
        }

        const currentVal = variantSelect.value;

        // Define desired options based on type
        let desiredOptions = [""];

        if (type === "Hero" || type === "Herói") {
            desiredOptions = ["", "Super Hero", "Infinity War", "Crisis", "Speedster", "Symbiote", "Unity", "Transformed", "Hero lvl 1", "Hero lvl 2", "Hero lvl 3", "Hero lvl 4", "Bribe 1", "Bribe 2", "Bribe 3", "Bribe 4", "Bribe 5"];
        } else if (type === "Villain" || type === "Vilão" || type === "Villain Nemesis" || type === "Vilão Nêmesis") {
            desiredOptions = ["", "Super-Villain", "Infinity War", "Crisis", "Speedster", "Symbiote", "Unity", "Transformed", "Impossible", "Villain lvl 1", "Villain lvl 2", "Villain lvl 3", "Villain lvl 4", "Bribe 1", "Bribe 2", "Bribe 3", "Bribe 4", "Bribe 5"];
        } else if (type === "Equipment" || type === "Equipamento") {
            desiredOptions = ["", "Symbiote"];
        }

        // Rebuild options
        variantSelect.innerHTML = "";
        desiredOptions.forEach((optVal) => {
            const opt = document.createElement("option");
            opt.value = optVal;
            opt.text = optVal;
            variantSelect.add(opt);
        });

        // Restore selection if valid
        if (desiredOptions.includes(currentVal)) {
            variantSelect.value = currentVal;
        } else {
            variantSelect.value = "";
            row.values.variant = "";
        }
    }

    private deleteCustomSet(originalName: string): void {
        // Remove from store
        let customSets = store.get("custom-sets") || [];
        customSets = customSets.filter((s: any) => s.original !== originalName);
        store.set("custom-sets", customSets);

        // Remove from memory
        const index = setsData.findIndex((s) => s.original === originalName);
        if (index !== -1) {
            setsData.splice(index, 1);
        }

        // Remove from dropdown
        const setSelect = this.defaultsTable.getRow(0).tr.querySelector(".column-set select") as HTMLSelectElement;
        if (setSelect) {
            for (let i = 0; i < setSelect.options.length; i++) {
                if (setSelect.options[i].value === originalName) {
                    setSelect.remove(i);
                    break;
                }
            }
            // If we deleted the currently selected one, reset to first
            if (setSelect.value === originalName) {
                setSelect.selectedIndex = 0;
                setSelect.dispatchEvent(new Event("change", { bubbles: true }));
            }
        }
    }

    private injectModalStyles(): void {
        if (document.getElementById("set-editor-styles")) {
            return;
        }
        const style = document.createElement("style");
        style.id = "set-editor-styles";
        style.innerHTML = `
            .set-editor-modal {
                position: fixed;
                z-index: 1000;
                left: 0;
                top: 0;
                width: 100%;
                height: 100%;
                background-color: rgba(0,0,0,0.6);
                display: flex;
                align-items: center;
                justify-content: center;
                font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            }
            .set-editor-modal .modal-content {
                background-color: #fff;
                color: #333;
                padding: 25px;
                border: none;
                width: 450px;
                border-radius: 15px;
                box-shadow: 0 10px 25px rgba(0,0,0,0.2);
            }
            .set-editor-modal h3 {
                margin-top: 0;
                color: #0056b3;
                border-bottom: 1px solid #e9ecef;
                padding-bottom: 10px;
                margin-bottom: 20px;
            }
            .set-editor-modal h4 {
                margin-bottom: 10px;
                color: #555;
            }
            .set-editor-modal form label {
                display: block;
                margin-top: 15px;
                font-weight: 600;
                font-size: 0.9em;
                color: #444;
            }
            .set-editor-modal form input[type="text"] {
                width: 100%;
                padding: 10px;
                box-sizing: border-box;
                border: 1px solid #ddd;
                border-radius: 8px;
                margin-top: 5px;
                font-size: 1em;
            }
            .set-editor-modal form input[type="text"]:focus {
                border-color: #ed1c24;
                outline: none;
            }
            .set-editor-modal form input[type="color"] {
                width: 100%;
                height: 40px;
                padding: 2px;
                box-sizing: border-box;
                border: 1px solid #ddd;
                border-radius: 8px;
                margin-top: 5px;
                cursor: pointer;
            }
            .set-editor-modal .modal-buttons {
                margin-top: 25px;
                text-align: right;
            }
            .set-editor-modal .modal-buttons button {
                margin-left: 10px;
                padding: 10px 20px;
                cursor: pointer;
                border: none;
                border-radius: 8px;
                font-weight: bold;
                transition: background 0.2s;
            }
            .set-editor-modal .save-button {
                background-color: #ed1c24;
                color: white;
            }
            .set-editor-modal .save-button:hover {
                background-color: #c41219;
            }
            .set-editor-modal .cancel-button {
                background-color: #e0e0e0;
                color: #333;
            }
            .set-editor-modal .cancel-button:hover {
                background-color: #d0d0d0;
            }
            .edit-sets-button {
                margin-left: 10px;
                cursor: pointer;
                background: none;
                border: none;
                font-size: 18px;
                vertical-align: middle;
                transition: transform 0.2s;
            }
            .edit-sets-button:hover {
                transform: scale(1.2);
            }
            .custom-sets-container {
                margin-top: 25px;
                border-top: 1px solid #eee;
                padding-top: 15px;
            }
            .custom-sets-list {
                list-style: none;
                padding: 0;
                max-height: 150px;
                overflow-y: auto;
                border: 1px solid #eee;
                border-radius: 8px;
            }
            .custom-sets-list li {
                display: flex;
                justify-content: space-between;
                align-items: center;
                padding: 10px;
                border-bottom: 1px solid #eee;
                background-color: #fafafa;
            }
            .custom-sets-list li:last-child {
                border-bottom: none;
            }
            .delete-set-btn {
                background: none;
                border: none;
                cursor: pointer;
                font-size: 1.2em;
                opacity: 0.6;
                transition: opacity 0.2s;
            }
            .delete-set-btn:hover {
                opacity: 1;
            }
        `;
        document.head.appendChild(style);
    }

    /**
     * Invoked when a row is added to the Custom Cards table
     * @param row the row that was added, we need to render it
     */
    private rowAdded(row: IRowData): void {
        const canvas = document.createElement("canvas");

        setTimeout(() => {
            canvas.classList.add("shown");
            row.tr.classList.add("shown");
        }, 50);

        const deleteButton = row.values.delete as HTMLButtonElement;
        deleteButton.addEventListener("click", () => {
            row.tr.classList.remove("shown");
            canvas.classList.remove("shown");
            this.checkMaxCards(this.cardsTable.rows.length - 1);

            setTimeout(() => {
                this.cardsTable.deleteRow(row);
            }, 355); // css animation variable
        });

        const card = new Card(row.values);
        this.cards.set(row, card);

        this.canvases.set(row, canvas);
        this.canvasesElement.appendChild(canvas);

        // Add download functionality on canvas click
        canvas.style.cursor = "pointer";
        canvas.addEventListener("click", () => {
            this.downloadCardAsImage(canvas, card.name);
        });

        setTimeout(() => this.addFileUploadToRow(row, "imageURL"), 100);

        this.renderCard(row);
        this.checkMaxCards(this.cardsTable.rows.length);
    }

    /**
     * Invoked when a row is deleted from the Custom Cards table
     * @param row the row that was deleted, we will remove its canvas and card
     */
    private rowDeleted(row: IRowData): void {
        this.updateStore(this.cardsTable);

        this.cards.delete(row);
        this.canvases.get(row).remove();
        this.canvases.delete(row);
    }

    /**
     * Adds a file upload button to the specified cell to allow local file usage
     */
    private addFileUploadToRow(row: IRowData, columnKey: string = "imageURL"): void {
        const cell = row.tr.querySelector(`.column-${columnKey}`) as HTMLElement;
        if (!cell) { return; }

        // Check if we already have the wrapper to avoid duplicates
        if (cell.querySelector(".file-upload-wrapper")) { return; }

        const input = cell.querySelector("input, textarea") as HTMLInputElement | HTMLTextAreaElement;
        if (!input) { return; }

        // Create wrapper to ensure input and button sit side-by-side correctly
        const wrapper = document.createElement("div");
        wrapper.className = "file-upload-wrapper";
        wrapper.style.display = "flex";
        wrapper.style.alignItems = "center";
        wrapper.style.width = "100%";

        // Move input into wrapper
        cell.appendChild(wrapper);
        wrapper.appendChild(input);

        input.style.flex = "1";
        input.style.width = "auto"; // Reset width to allow flex to work
        input.style.minWidth = "0"; // Prevent flex overflow

        const btn = document.createElement("button");
        btn.innerHTML = "📂";
        btn.className = "file-upload-btn";
        btn.title = "Upload local image";
        btn.type = "button";
        btn.style.marginLeft = "5px";
        btn.style.cursor = "pointer";
        btn.style.border = "none";
        btn.style.background = "transparent";
        btn.style.fontSize = "1.2em";
        btn.style.padding = "0";
        btn.style.lineHeight = "1";
        btn.style.flexShrink = "0"; // Prevent button from being squashed

        const fileInput = document.createElement("input");
        fileInput.type = "file";
        fileInput.accept = "image/*";
        fileInput.style.display = "none";

        btn.addEventListener("click", (e) => {
            e.stopPropagation();
            fileInput.click();
        });

        fileInput.addEventListener("change", () => {
            if (fileInput.files && fileInput.files[0]) {
                const file = fileInput.files[0];

                const reader = new FileReader();
                reader.onload = (e) => {
                    const url = e.target.result as string;
                    input.value = url;
                    if (row.values) {
                        (row.values as any)[columnKey] = url;
                    }
                    // Trigger change for the table logic
                    input.dispatchEvent(new Event("change", { bubbles: true }));
                };
                reader.readAsDataURL(file);
            }
        });

        wrapper.appendChild(btn);
        wrapper.appendChild(fileInput);
    }

    /**
     * (re) renders all cards, invoked when a card wide (Card Default) row is
     * edited
     */
    private renderAllCards(): void {
        for (const row of this.cardsTable.getAllRows()) {
            this.renderCard(row);
        }
    }

    /**
     * (re)-renders a card to its canvas asynchronous
     * @param row the row of the card to render
     */
    private renderCard(row: IRowData): void {
        const card = this.cards.get(row);
        const canvas = this.canvases.get(row);

        // clear the renderer
        this.clearGraphics.beginFill(0x000000, 0);
        this.clearGraphics.drawRect(0, 0, card.pxWidth, card.pxHeight);

        const defaults = clone(this.defaultsTable.getRow(0).values);
        const args = clone(defaults, row.values);

        // Logic for alternating languages
        const rowIndex = this.cardsTable.rows.indexOf(row);
        
        // Find the set entry based on the original name selected in defaults
        const setEntry = setsData.find((s) => s.original === defaults.set);

        if (setEntry) {
            // If odd row (1, 3, 5...), use Portuguese set name, else use new English name
            if (rowIndex % 2 !== 0) { args.set = setEntry.pt; }
            else { args.set = setEntry.en; }
        }

        card.setFrom(args);

        card.render().then((container: PIXI.Container) => {
            this.checkForErrors(row, card);

            this.app.stage.addChild(container);
            this.app.render();

            canvas.width = card.pxWidth;
            canvas.height = card.pxHeight;
            canvas.getContext("2d").drawImage(this.app.view, 0, 0);
            this.app.stage.removeChild(container);

            this.resizeCanvases(canvas);
        });
    }

    /**
     * Resizes all card canvases. Invoked when the scale slider is changed
     * @param canvas a specific and singular canvas to scale, or all if this
     *               is omitted
     */
    private resizeCanvases(canvas?: HTMLCanvasElement): void {
        const scale = Number(this.scaleSlider.value);
        const asPercent = Math.round(scale * 10000) / 100;
        this.scaleSliderPercent.innerHTML = `${asPercent}%`;
        store.set("card-scale", scale);

        let elements;
        if (canvas) {
            elements = [canvas];
        }
        else {
            elements = this.canvasesElement.getElementsByTagName("canvas");
        }

        for (const element of elements) {
            const width = Number(element.getAttribute("width"));
            const height = Number(element.getAttribute("height"));

            element.style.width = `${width * scale}px`;
            element.style.height = `${height * scale}px`;
        }
    }

    /**
     * Checks for errors such as image url cells that are invalid urls that
     * cannot be loaded
     * @param row the row to check for errors in
     * @param card the card to check for errors in
     */
    private checkForErrors(row: IRowData, card: Card): void {
        this.checkIfImageLoaded(row, card, "imageURL");
        this.checkIfImageLoaded(this.defaultsTable.rows[0], card, "logoURL");
    }

    /**
     * Checks if a given image URL has been loaded into the PIXI.Loader
     * @param row the row to check for
     * @param card the card to card images from
     * @param key the column key we are checking, such as 'imageURL' or
     *            'logoURL'
     */
    private checkIfImageLoaded(row: IRowData, card: Card, key: string): void {
        const resource = PIXI.loader.resources[(card as any)[key]];
        const td = row.tr.getElementsByClassName(`column-${key}`)[0];

        td.classList.toggle("error", Boolean(resource.error) || !resource || !resource.texture);
    }

    /**
     * Updates the store library with custom cards so page reloads do not loose
     * card editing progress
     * @param table the table to store
     */
    private updateStore(table: EditableTable): void {
        const storeKey = table === this.cardsTable
            ? "cards"
            : "card-defaults";

        store.set(storeKey, table.rows.map((row: IRowData) => row.values));
    }

    /**
     * Resets all EditableTables to their default values, and clears stores
     */
    private resetToDefaults(): void {
        const cards = this.cardsTable.rows.slice();
        for (const row of cards) {
            row.tr.classList.remove("shown");
            this.canvases.get(row).classList.remove("shown");
        }

        const defaults = this.defaultsTable.rows.slice();
        for (const row of defaults) {
            row.tr.classList.remove("shown");
        }

        this.scaleSlider.value = String(0.5);

        setTimeout(() => {
            for (const row of cards) {
                this.cardsTable.deleteRow(row);
            }

            for (const row of defaults) {
                this.defaultsTable.deleteRow(row);
            }

            setTimeout(() => {
                this.defaultsTable.addRows(defaultsRows);
                this.updateStore(this.defaultsTable);

                this.cardsTable.addRows(cardsRows);
                this.updateStore(this.cardsTable);
            }, 50);
        }, 355);
    }

    /**
     * Checks if the user hit the maximum number of cards and we need to show or
     * hide elements accordingly
     * @param numberOfCards the number of cards there will be
     */
    private checkMaxCards(numberOfCards: number): void {
        const tooManyCards = (numberOfCards >= this.maxCustomCards);

        this.addRowButton.disabled = tooManyCards;
        this.tooManyCardsElement.classList.toggle("collapsed", !tooManyCards);
    }

    /**
     * Downloads a card canvas as a PNG image
     * @param canvas the canvas element to download
     * @param cardName the name of the card (used for the filename)
     */
    private downloadCardAsImage(canvas: HTMLCanvasElement, cardName: string): void {
        const link = document.createElement("a");
        link.href = canvas.toDataURL("image/png");
        link.download = `${cardName || "card"}.png`;
        link.click();
    }
}
