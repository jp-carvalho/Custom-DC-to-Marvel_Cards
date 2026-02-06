/** The tables present by default in the LiveEditorTab */

import { CardOptions } from "src/cards/card/card-options";
import { IColumnData, IRowData, IRowValues, RowValue } from "src/gui/table";
import * as store from "store";
import { stripTagsFromString } from "src/utils/";

function addTitlesTo(columns: IColumnData[]): void {
    for (const column of columns) {
        let name: string = column.name;

        if (name === "Delete") {
            continue; // skip, special column we add that is not a normal option
        }

        if (name === "Edit Set") {
            continue;
        }

        if (name === "VP") {
            name = "Victory Points";
        }

        column.rowsTitle = stripTagsFromString(CardOptions[name].description);
    }
}

const deleteButton = document.createElement("button");
deleteButton.innerHTML = "&#x2716;";
deleteButton.setAttribute("title", "Delete this row");

export const setsData = [
    { original: "Base", en: "", pt: "", text: "#000000", bg: "#000000" },
    { original: "Promo", en: "Promo", pt: "Promo", text: "#c49104", bg: "#000000" },
    { original: "Heroes Unite", en: "Avengers Assemble", pt: "Avante Vingadores", text: "#FFD700", bg: "#003366" },
    { original: "Forever Evil", en: "Dark Avengers", pt: "Vingadores Sombrios", text: "#FFFFFF", bg: "#5C0000" },
    { original: "Teen Titans", en: "Team-Up", pt: "Parceria Marvel", text: "#FFFFFF", bg: "#E23636" },
    { original: "Dark Nights Metal", en: "King In Black", pt: "Rei das trevas", text: "#FF0000", bg: "#000000" },
    { original: "Rebirth", en: "Secret Wars", pt: "Guerras Secretas", text: "#00E5FF", bg: "#1A1A1A" },
    { original: "Rebirth2", en: "Secret Wars 2", pt: "Guerras Secretas 2", text: "#03717e", bg: "#3a3939" },
    { original: "Injustice", en: "Civil War II", pt: "Guerra Civil II", text: "#212121", bg: "#FFB400" },
    { original: "Crossover1", en: "Crossover 1", pt: "Incursão 1", text: "#F0E68C", bg: "#354A21" },
    { original: "Crossover2", en: "Crossover 2", pt: "Incursão 2", text: "#E6E6E6", bg: "#4B0082" },
    { original: "Crossover3", en: "Crossover 3", pt: "Incursão 3", text: "#FFFFFF", bg: "#002395" },
    { original: "Crossover4", en: "Crossover 4", pt: "Incursão 4", text: "#BFFF00", bg: "#1B3B1B" },
    { original: "Crossover5", en: "Crossover 5", pt: "Incursão 5", text: "#FF4500", bg: "#2D2D2D" },
    { original: "Crossover6", en: "Crossover 6", pt: "Incursão 6", text: "#FFFFFF", bg: "#800080" },
    { original: "Crossover7", en: "Crossover 7", pt: "Incursão 7", text: "#FFD700", bg: "#721414" },
    { original: "Crossover8", en: "Crossover 8", pt: "Incursão 8", text: "#FF0000", bg: "#0045A5" },
    { original: "Crossover9", en: "Crossover 9", pt: "Incursão 9", text: "#E3D4A2", bg: "#3B2314" },
    { original: "Crossover10", en: "Crossover 10", pt: "Incursão 10", text: "#F8F8FF", bg: "#483D8B" },
    { original: "Crossover11", en: "Crossover 11", pt: "Incursão 11", text: "#FFFFFF", bg: "#008080" },
    { original: "Crossover12", en: "Hush", pt: "Incursão 12", text: "#FFFFFF", bg: "#8B4513" },
    { original: "Crisis1", en: "Infinity War 1", pt: "Guerra do Infinito 1", text: "#FFF4BD", bg: "#B8860B" },
    { original: "Crisis2", en: "Infinity War 2", pt: "Guerra do Infinito 2", text: "#FFE066", bg: "#916A08" },
    { original: "Crisis3", en: "Infinity War 3", pt: "Guerra do Infinito 3", text: "#FFCC00", bg: "#6B4F06" },
    { original: "Crisis4", en: "Infinity War 4", pt: "Guerra do Infinito 4", text: "#E6B800", bg: "#453304" },
    { original: "Crisis5", en: "Infinity War 5", pt: "Guerra do Infinito 5", text: "#B38F00", bg: "#211902" },
    { original: "Confrontations", en: "Civil War", pt: "Guerra Civil", text: "#626060", bg: "#303030" },
    { original: "Arkam Asylum", en: "Ravencroft", pt: "Ravencroft", text: "#00FF7F", bg: "#001A00" },
    { original: "Teen Titans Go", en: "Team-Up 90's", pt: "Parceria Marvel 90's", text: "#F0F0F0", bg: "#FF007F" },
    { original: "Teen Titans Go 2", en: "Team-Up 90's 2", pt: "P. Marvel 90's 2", text: "#F0F0F0", bg: "#eb107d" },
    { original: "Justice League dark", en: "Midnight Suns", pt: "Filhos da Meia-Noite", text: "#FFD700", bg: "#191970" },
    { original: "AA Shadows", en: "The Vault", pt: "O Cofre", text: "#000000", bg: "#A9A9A9" },
    { original: "Multiverse", en: "Marvels", pt: "Marvels", text: "#F5F5DC", bg: "#5D4037" },
    { original: "Rivals 1", en: "Rivals 1", pt: "Confronto 1", text: "#ffec34", bg: "#ed1c24" },
    { original: "Rivals 2", en: "Rivals 2", pt: "Confronto 2", text: "#37a987", bg: "#126818" },
    { original: "Rivals 3", en: "Rivals 3", pt: "Confronto 3", text: "#FFFAFA", bg: "#D22B2B" },
    { original: "Rivals 4", en: "Rivals 4", pt: "Confronto 4", text: "#B0E0E6", bg: "#00008B" },
    { original: "Rivals 5", en: "Rivals 5", pt: "Confronto 5", text: "#7CFC00", bg: "#002200" },
    { original: "Peacemaker", en: "Shooters", pt: "Atiradores", text: "#FFFFFF", bg: "#708090" },
    { original: "Crossover Crisis 1", en: "CIW 1", pt: "IGI 1", text: "#FFFFFF", bg: "#2E8B57" },
];

const customSets = store.get("custom-sets") || [];
setsData.push(...customSets);

/** the headings for the cards defaults table on the LiveEditorTable */
export const defaultsHeadings: IColumnData[] = [
    {
        name: "Edit Set",
        id: "name",
        notEditable: true,
    },
    {
        name: "Set",
        allowedValues: setsData.map((s) => s.original).sort((a, b) => a.localeCompare(b, undefined, { numeric: true })),
    },
    {
        name: "Set Text Color",
        color: true,
    },
    {
        name: "Set Background Color",
        color: true,
    },
    {
        name: "Copyright",
    },
    {
        name: "Legal",
        longText: true,
    },
    {
        name: "Logo URL",
    },
    {
        name: "Logo Scale",
        type: "number",
        inputAttributes: {
            step: 0.001,
            min: 0.010,
            max: 2,
            step: 0.001,
        },
    },
];

addTitlesTo(defaultsHeadings);

/** the rows for the cards defaults table on the LiveEditorTable */
export const defaultsRows: IRowValues[] = [
    {
        name: "__defaults__",
        logoURL: "https://i.imgur.com/UFuNhQp.png",
        set: "Teen Titans",
        setTextColor: "#ffec34",
        setBackgroundColor: "#ed1c24",
        copyright: "2015 CZE",
        legal: "TEEN TITANS and all related character and elements are trademarks and © DC Comics\n(s15)",
        logoScale: 1.0,
    },
    /*{
        name: '__oversized_defaults__',
        logoScale: 0.975,
        setTextColor: '#ffec34',
        setBackgroundColor: '#ed1c24',
    },*/
];

/** the headings for the custom cards table on the LiveEditorTable */
export const cardsHeadings: IColumnData[] = [
    {
        name: "Name",
    },
    {
        name: "Type",
        allowedValues: ["Equipment", "Hero", "Location", "Starter", "Super Power", "Villain", "Villain Nemesis", "Weakness"],
    },
    {
        name: "Text",
        longText: true,
    },
    {
        name: "Cost",
    },
    {
        name: "VP",
        id: "victoryPoints",
    },
    {
        name: "Subtype",
    },
    {
        name: "Variant",
        allowedValues: ["", "Super Hero", "Super-Villain", "Impossible", "Hero lvl 1", "Hero lvl 2", "Hero lvl 3", "Hero lvl 4", "Villain lvl 1", "Villain lvl 2", "Villain lvl 3", "Villain lvl 4", "Infinity War", "Crisis", "Speedster", "Symbiote", "Unity", "Bribe 1", "Bribe 2", "Bribe 3", "Bribe 4", "Bribe 5"],
    },
    {
        name: "Oversized",
        type: "boolean",
        transform: (checked: RowValue, row: IRowData) => {
            const type = row.values.type;
            if (checked && type !== "Hero" && type !== "Villain" && type !== "Herói" && type !== "Vilão" && type !== "Heroi" && type !== "Villain Nemesis" && type !== "Vilão Nêmesis") {
                return false;
            }
            return checked;
        },
    },
    {
        name: "Image URL",
    },
    {
        name: "Delete",
        type: "node",
        defaultValue: deleteButton,
    },
];

addTitlesTo(cardsHeadings);

/** the rows for the custom cards table on the LiveEditorTable */
export const cardsRows: IRowValues[] = [
    {
        name: "Vulnerability",
        type: "Starter",
        text: "",
        imageURL: "https://i.imgur.com/em2ZPJG.png",
        vp: 0,
        cost: 0,
    },
    {
        name: "Wonder Girl",
        type: "Hero",
        oversized: true,
        imageURL: "https://i.imgur.com/RjNwCAX.png",
        text: "Once during each of your turns, if you control two or more "
            + "Equipment, draw two cards and then discard a card.",
    },
];
