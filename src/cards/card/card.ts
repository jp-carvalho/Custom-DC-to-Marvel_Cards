import {
    autoSizeAndWrapStyledText, loadTextures, newSprite, replaceAll,
    surroundText, wrapStyledText, wrapStyledTextCharacters,
} from "src/utils/";
import { getStyle } from "./card-styles";

/** Card type translations */
const cardTypeTranslations: {[key: string]: string} = {
    "Equipment": "Equipment",
    "Hero": "Hero",
    "Location": "Location",
    "Starter": "Starter",
    "Super Power": "Super Power",
    "Villain": "Villain",
    "Weakness": "Weakness",
    "Equipamento": "Equipamento",
    "Herói": "Herói",
    "Heroi": "Herói",
    "Localização": "Localização",
    "Inicial": "Inicial",
    "Super Poder": "Superpoder",
    "Fraqueza": "Fraqueza",
    "Villain Nemesis": "Nemesis",
    "Vilão Nêmesis": "Nêmesis",
};

/** The maximum width (in pixels) that a card can be (oversized) */
export const CARD_MAX_WIDTH = 900;

/** The maximum height (in pixels) that a card can be (oversized) */
export const CARD_MAX_HEIGHT = 1200;

/**
 * represents a custom card
 */
export class Card {
    /** Keywords that are automatically bolded for all card text */
    public static readonly autoBoldKeywords = [
        "WHEN YOU GAIN THIS: Investigate",
        "AO GANHAR ISSO: Investigue",
        "Ataque Surpresa!",
        "Ataque de Emboscada!",
        "Investigate",
        "Investigue",
        "+Power",
        "Power",
        "+Poder",
        "Poder",
        ":",
        "Defense",
        "Weakness",
        "Atacado",
        "Ataque",
        "Defensa",
        "Fraqueza",
        "Confrontation",
        "Confronto",
        "Speedster",
        "Velocista",
        "Once per turn",
        "Uma vez por turno",
        "Reward",
        "Recompensa",
        "Once during each of your turns",
        "Uma vez durante cada um dos seus turnos",
        "Range",
        "Alcance",
        "Contínuo",
        "Contínuas",
        "Defesa",
        "Surge",
        "Stack Ongoing",
        "Pilha Contínua",
        "Once per Turn",
        "Uma vez por Turno",
        "Block",
        "Bloqueio",
        "Discard 2 different cards",
        "Descarte 2 cartas diferentes",
        "Vulnerability ",
        "Vulnerabilidade ",
        "Discard two cards",
        "Descarte duas cartas",
        // "Discard 2 cards",
        // "Descarte 2 cartas",
        "Teamwork",
        "Trabalho em Equipe",
        "Punch",
        "Soco",
        "Ambush",
        "Surpresa",
        "UNAVOIDABLE",
        "INDEFENSÁVEL",
        "Once during your turn",
        "Once this turn",
        "Uma vez neste turno",
        "Uma vez durante o seu turno",
        "Bribe",
        "Suborno",
        "End of Your Turn",
        "Fim do Seu Turno",
        "SYMBIOTE",
        "SIMBIONTE",
        "Discard a Super Power",
        "Descarte um Superpoder",
        "Once per your turns",
        "Time Travel",
        "Eco Temporal",
        "Bombshell",
        "Bombástico",
        "WHEN YOU GAIN THIS: Investigate.",
        "AO GANHAR ISSO: Investigue",
        "Ataque Surpresa!",
        "Seal a Location you control",
        "Sele uma Localização que você controla",
        "Once per your turn",
        "Start of your turn",
        "Início do seu turno",
        "Area",
        "em Área",
        "END OF GAME",
        "FIM DE JOGO",
        "Sidekicks",
        "Ajudantes",
        "Seal",
        "Sele",
        "Selar",
    ];

    /** Configuration for highlighting specific phrases with background colors */
    public static readonly highlightConfigs = [
        {
            color: 0xe1b327, // Amarelo
            phrases: [
                "WHEN YOU GAIN THIS: GAIN A WEAKNESS.",
                "When you buy or gain this card, gain 1 VP.",
                "AO GANHAR ISTO: GANHE UMA FRAQUEZA.",
                "Quando você comprar ou ganhar esta carta, ganhe 1 PV.",
                "WHEN YOU GAIN THIS: Investigate, then shuffle 2 Ambush Attack! cards into the Investigation deck.",
                "AO GANHAR ISSO: Investigue e, em seguida, embaralhe 2 cartas de Ataque Surpresa! no baralho de Investigação.",
            ],
        },
        {
            color: 0xa1dfff, // Azul (#a1dfff)
            phrases: [
                "If you destroy or discard this card from your hand, deck, or discard pile, gain it and put it into your hand.",
                "Se você destruir ou descartar esta carta de sua mão, baralho ou pilha de descarte, ganhe-a e coloque-a em sua mão.",
            ],
        },
    ];

    /** The current width in pixels of the rendered card */
    public pxWidth = CARD_MAX_WIDTH;

    /** The current height in pixels of the rendered card */
    public pxHeight = CARD_MAX_HEIGHT;

    /** The name of the card */
    public name: string = "Card Name";

    /** The type of the card, used for background generation */
    public type: "Equipment" | "Hero" | "Location" | "Starter" | "Equipamento" |
                 "Super Power" | "Villain" | "Weakness" | "Herói" | "Localização" | "Inicial" | "Superpoder" | "Vilão" | "Fraqueza" |
                 "Weakness" | "Villain Nemesis" | "Vilão Nêmesis" = "Starter";

    /** If this card is a variant with black background text */
    public variant: string = "";

    /** If this card is oversized */
    public oversized: boolean = false;

    /** A string prefix to place in front of this card's type */
    public typePrefix: string = "";

    /** The number of VP this card is worth at the end of the game */
    public victoryPoints: string | number = 1;

    /** How much this card costs to buy */
    public cost: string | number = 1;

    /** The text on the card. You can use [b] and [i] to bold and italic text */
    public text: string = "";

    /** The url to the image to use for this card */
    public imageURL: string = "";

    /** The url to the image to use for its upper right logo */
    public logoURL: string = "";

    /** A scalar to apply to the logo's size */
    public logoScale: number = 1;

    /** The copyright text, A © is automatically placed in front of this text */
    public copyright: string = String(new Date().getFullYear());

    /** The legal disclaimer on the bottom of the card */
    public legal: string = "";

    /** The sub type of the card next to the type */
    public subtype: string = "";

    /** The name of the set this card is a part of */
    public set: string = "";

    /** The color of the name of this card's set */
    public setTextColor = "#cccccc";

    /** The background color of the rounded box behind the set text */
    public setBackgroundColor = "#333333";

    /**
     * The preferred starting text size number to start at when auto sizing the
     * text. If the number is too large it will be ignored and down-scaled
     */
    public preferredTextSize: number = 0;

    /** A list of string to bold if they are encountered in the text */
    public alsoBold: string[] = [];

    /** If the corners of the card should be rounded */
    public roundCorners: boolean = true;

    /** The PIXI.Container this card's render is in */
    private container: PIXI.Container;

    /**
     * Creates a card from so key/value object
     * @param args optional args to call setFrom on
     */
    constructor(args?: {[key: string]: any}) {
        if (args) {
            this.setFrom(args);
        }
    }

    /**
     * Sets this card's internal variables from a key/value object
     * @param args the args to set; so to set imageURL, set args.imageURL
     */
    public setFrom(args: {[key: string]: any}): void {
        args = Object.assign({}, args);
        args.victoryPoints = args.victoryPoints || args.vp || args.VP || args.vP || 0;

        for (const key in args) {
            if (Object.prototype.hasOwnProperty.call(this, key)) {
                (this as any)[key] = args[key];
            }
        }

        // special cases, we can take "Super Hero/Villain" as a type
        // (which is invalid) and make it the oversized version
        if (this.type as any === "Super Hero") {
            this.type = "Hero";
            this.oversized = true;
        }
        else if (this.type as any === "Super Villain") {
            this.type = "Villain";
            this.oversized = true;
        }

        if (this.variant === "Infinity War" || this.variant === "Crisis") {
            this.oversized = true;
        }

        const isHeroOrVillain = this.type === "Hero" || this.type === "Villain" ||
                                this.type === "Vilão" || this.type === "Herói" ||
                                this.type === "Heroi" || this.type === "Vilao" ||
                                this.type === "Villain Nemesis" || this.type === "Vilão Nêmesis";
        if (this.oversized && !isHeroOrVillain) {
            this.oversized = false;
        }

        if (this.oversized) {
            this.pxWidth = CARD_MAX_WIDTH;
            this.pxHeight = CARD_MAX_HEIGHT;
        }
        else {
            this.pxWidth = 750;
            this.pxHeight = 1050;
        }
    }

    /**
     * Rendered the card asynchronously to a PIXI.Container
     * This method will load textures
     * @returns a promise that resolves to a rendered PIXI.Container with no
     *          parent
     */
    public render(): Promise<PIXI.Container> {
        return new Promise((resolve, reject) => {
            loadTextures([this.imageURL, this.logoURL], () => {
                this.renderSync();

                resolve(this.container);
            });
        });
    }

    /**
     * Renders a card synchronously, must be invoked after textures are already
     * loaded
     * @returns a PIXI.Container with no parent of the rendered card
     */
    public renderSync(): PIXI.Container {
        if (this.container) {
            this.container.removeChild(this.container);
        }

        this.container = new PIXI.Container();

        this.renderImage();
        this.renderBackground();
        this.renderLogo();

        this.renderCost();
        this.renderVP();

        this.renderName();
        this.renderType();
        this.renderSubType();

        this.renderText();

        const copyright = this.renderCopyright();
        const set = this.renderSet(copyright);
        this.renderLegal(set, copyright);

        this.renderRoundedCorners();

        return this.container;
    }

    /**
     * A handy toString override that tells you this card's name
     * @returns card plus its name
     */
    public toString(): string {
        return `Card ${this.name}`;
    }

    /**
     * Formats the text, checking for keywords to bold or italic automatically
     * @returns the text now with bold and italic formatting tags inserted
     */
    private formatText(): string {
        let formattedText = this.text;

        formattedText = formattedText.replace(/Meter Burn \((\d+)\)/gi, "[b]Meter Burn __LP__$1__RP__[/b]");
        formattedText = formattedText.replace(/Queima da barra \((\d+)\)/gi, "[b]Queima da barra __LP__$1__RP__[/b]");

        const blockPhrases: string[] = [];
        formattedText = formattedText.replace(/(Block|Bloqueio)(\s*)\((\d+)\)/gi, (match, p1, p2, p3) => {
            blockPhrases.push(`${p1}${p2}(${p3})`);
            return `__BLOCK_PHRASE_${blockPhrases.length - 1}__`;
        });

        formattedText = surroundText(formattedText, /\(([^)]+)\)/g, "[i]", "[/i]");
        formattedText = formattedText.replace(/__LP__/g, "(");
        formattedText = formattedText.replace(/__RP__/g, ")");

        formattedText = formattedText.replace(/(Range:|Alcance:)(\s*)(\d+)/gi, "$1$2[b]$3[/b]");

        formattedText = formattedText.replace(/(Stack\ Ongoing)|(Ongoing)/g, (match, p1, p2) => {
            return p1 ? "[b]Stack Ongoing[/b]" : "[b]Ongoing[/b]";
        });
        formattedText = formattedText.replace(/(Pilha\ Contínua)|(Contínua)(?!s)/g, (match, p1, p2) => {
            return p1 ? "[b]Pilha Contínua[/b]" : "[b]Contínua[/b]";
        });

        // Protect phrases that contain keywords but should not be bolded themselves
        const neutralProtected: string[] = [];
        const phrasesToProtectNeutrally = [
            /Super\s*Power(s)?/gi,
            /Super\s*Poder(es)?/gi,
        ];

        for (const regex of phrasesToProtectNeutrally) {
            formattedText = formattedText.replace(regex, (match) => {
                neutralProtected.push(match);
                return `__NEUTRAL_PROTECTED_${neutralProtected.length - 1}__`;
            });
        }

        // Manual bolding with {}
        const manualBolds: string[] = [];
        formattedText = formattedText.replace(/\{([^{}]+)\}/g, (match, content) => {
            manualBolds.push(content);
            return `__MANUAL_BOLD_${manualBolds.length - 1}__`;
        });

        // Handle highlightConfigs with protection to avoid inner keyword bolding
        const highlightPlaceholders: string[] = [];
        for (const config of Card.highlightConfigs) {
            for (const phrase of config.phrases) {
                const escaped = phrase.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
                const regex = new RegExp(escaped, 'gi');
                formattedText = formattedText.replace(regex, (match) => {
                    highlightPlaceholders.push(`[b]${match}[/b]`);
                    return `__HIGHLIGHT_PHRASE_${highlightPlaceholders.length - 1}__`;
                });
            }
        }

        // Temporarily protect the phrases to prevent double-bolding of keywords within them.
        const protectedPhrases: string[] = [];
        const phrasesToProtect = [
            /(Galactus Herald:\s*\d+)/gi,
            /(Arauto de Galactus:\s*\d+)/gi,
            /First\ Appearance\s*[—–-]\s*Attack/gi,
            /Primeira\ Aparição\s*[—–-]\s*Ataque/gi,
            /\+([\d\sX]*?)\ Power/gi,
            /\+([\d\sX]*?)\ de\ Poder/gi,
            /(\d+)\s*\+\s*Power/gi,
            /(\d+)\s*\+\s*de\ Poder/gi,
            /(\d)\ Power/gi,
            /Pay\s*[1-9]\s*VPs/gi,
            /Pague\s*[1-9]\s*PVs/gi,
            /(Discard a non-Weakness card)/gi,
            /(Descarte uma carta de não-Fraqueza)/gi,
            /\bReverter\b/gi,
            /\bRevert\b/gi,
            /\bTransformar\b/gi,
            /\bTransform\b/gi,
        ];

        for (const regex of phrasesToProtect) {
            formattedText = formattedText.replace(regex, (match) => {
                protectedPhrases.push(match);
                return `__PROTECTED_PHRASE_${protectedPhrases.length - 1}__`;
            });
        }

        formattedText = formattedText.replace(/\b(Attack)\b/gi, "[b]$1[/b]");

        const boldKeywords = Card.autoBoldKeywords.concat(this.alsoBold);

        for (const toBold of boldKeywords) {
            const escaped = toBold.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
            const regex = new RegExp(escaped, 'gi');
            formattedText = formattedText.replace(regex, (match) => `[b]${match}[/b]`);
        }

        // Restore manual bolds
        for (let i = 0; i < manualBolds.length; i++) {
            formattedText = formattedText.replace(`__MANUAL_BOLD_${i}__`, `[b]${manualBolds[i]}[/b]`);
        }

        // Restore highlight phrases
        for (let i = 0; i < highlightPlaceholders.length; i++) {
            formattedText = formattedText.replace(`__HIGHLIGHT_PHRASE_${i}__`, highlightPlaceholders[i]);
        }

        // Restore neutral protected phrases
        for (let i = 0; i < neutralProtected.length; i++) {
            formattedText = formattedText.replace(`__NEUTRAL_PROTECTED_${i}__`, neutralProtected[i]);
        }

        // Restore the protected phrases, now fully bolded.
        for (let i = 0; i < protectedPhrases.length; i++) {
            formattedText = formattedText.replace(`__PROTECTED_PHRASE_${i}__`, `[b]${protectedPhrases[i]}[/b]`);
        }

        for (let i = 0; i < blockPhrases.length; i++) {
            formattedText = formattedText.replace(`__BLOCK_PHRASE_${i}__`, `[b]${blockPhrases[i]}[/b]`);
        }

        return formattedText;
    }

    /**
     * Gets the PIXI.TextStyle for a part of the card
     * @param part the part of the card to get the style for
     * @returns the style for that part of the card, if found
     */
    private getStyle(part: string): PIXI.TextStyle {
        return getStyle(this.type, part, this.oversized);
    }

    /**
     * Renders the image part of the card
     */
    private renderImage(): void {
        if (!this.imageURL) {
            return;
        }

        let imageMaxWidth = 750;
        let imageMaxHeight = 523;
        let imageTop = 117;
        if (this.oversized) {
            imageMaxWidth = 900;
            imageMaxHeight = 741;
            imageTop = 216;
        }

        if (this.variant === "MC Transform") {
            imageMaxHeight += 40;
        }

        const backgroundImage = newSprite(this.imageURL, this.container);
        backgroundImage.position.x = imageMaxWidth / 2;
        backgroundImage.position.y = imageTop + imageMaxHeight / 2;

        let backgroundBounds = backgroundImage.getBounds();
        const scale = Math.max(
            imageMaxWidth / backgroundBounds.width,
            imageMaxHeight / backgroundBounds.height,
        );

        backgroundBounds = backgroundImage.getLocalBounds();

        backgroundImage.scale.set(scale, scale);
        backgroundImage.pivot.x = backgroundBounds.width / 2;

        if (this.oversized) {
            backgroundImage.pivot.y = backgroundBounds.height / 2;
        } else {
            backgroundImage.pivot.y = 0;
            backgroundImage.position.y = imageTop;
        }

        const backgroundImageMask = new PIXI.Graphics();
        backgroundImageMask.beginFill(0);
        backgroundImageMask.drawRect(0, imageTop,
                                     imageMaxWidth, imageMaxHeight);
        backgroundImageMask.endFill();

        this.container.addChild(backgroundImageMask);
        backgroundImage.mask = backgroundImageMask;
    }

    /**
     * Renders the background part of the card based on the card's type
     */
    private renderBackground(): void {
        if (!this.type) {
            return;
        }

        let backgroundType: string;
        let spriteName: string;

        if (this.variant === "Impossible" && (this.type === "Villain" || this.type === "Vilão" || this.type === "Villain Nemesis" || this.type === "Vilão Nêmesis") && !this.oversized) {
            if (this.type === "Villain" || this.type === "Villain Nemesis") {
                spriteName = "super-villain imp";
            } else { // Vilão
                spriteName = "super-vilão imp";
            }
        } else if (this.variant.indexOf("Hero lvl") === 0 && (this.type === "Hero" || this.type === "Herói") && !this.oversized) {
            const lvl = this.variant.split(" ")[2];
            if (this.type === "Hero") {
                spriteName = `super-hero lvl${lvl}`;
            } else { // Herói
                spriteName = `super-heroi lvl${lvl}`;
            }
        } else if (this.variant.indexOf("Villain lvl") === 0 && (this.type === "Villain" || this.type === "Vilão" || this.type === "Villain Nemesis" || this.type === "Vilão Nêmesis") && !this.oversized) {
            const lvl = this.variant.split(" ")[2];
            if (this.type === "Villain" || this.type === "Villain Nemesis") {
                spriteName = `super-villain lvl${lvl}`;
            } else { // Vilão
                spriteName = `super-vilão lvl${lvl}`;
            }
        } else if (this.variant === "Crisis") {
            if (this.type === "Hero") {
                spriteName = "crisis super-hero";
            } else if (this.type === "Herói" || this.type === "Heroi") {
                spriteName = "crisis super-heroi";
            } else if (this.type === "Villain" || this.type === "Villain Nemesis") {
                spriteName = "Crisis super-villain";
            } else if (this.type === "Vilão" || this.type === "Vilao" || this.type === "Vilão Nêmesis") {
                spriteName = "Crisis super-vilão";
            }
        } else if (this.variant === "Infinity War") {
            if (this.type === "Hero") {
                spriteName = "sup-hero-infinity-war";
            } else if (this.type === "Herói" || this.type === "Heroi") {
                spriteName = "sup-heroi-guerra-infinita";
            } else if (this.type === "Villain" || this.type === "Villain Nemesis") {
                spriteName = "sup-villain-infinity-war";
            } else if (this.type === "Vilão" || this.type === "Vilao" || this.type === "Vilão Nêmesis") {
                spriteName = "sup-vilão-guerra-infinita";
            }
        } else if (this.variant === "Speedster" && !this.oversized) {
            if (this.type === "Hero" || this.type === "Herói" || this.type === "Heroi") {
                spriteName = "Speedster hero";
            } else if (this.type === "Villain" || this.type === "Vilão" || this.type === "Vilao" || this.type === "Villain Nemesis" || this.type === "Vilão Nêmesis") {
                spriteName = "Speedster villain";
            }
        } else if (this.variant === "Symbiote") {
            if (this.type === "Hero") {
                spriteName = "Symbiote hero";
            } else if (this.type === "Herói" || this.type === "Heroi") {
                spriteName = "Symbiote heroi";
            } else if (this.type === "Villain" || this.type === "Villain Nemesis") {
                spriteName = "Symbiote villain";
            } else if (this.type === "Vilão" || this.type === "Vilao" || this.type === "Vilão Nêmesis") {
                spriteName = "Symbiote vilão";
            } else if (this.type === "Equipment") {
                spriteName = "Symbiote equipment";
            } else if (this.type === "Equipamento") {
                spriteName = "Symbiote equipamento";
            }
        } else if (this.variant === "Unity") {
            if (this.type === "Hero" || this.type === "Herói" || this.type === "Heroi") {
                spriteName = "Unity hero";
            } else if (this.type === "Villain" || this.type === "Vilão" || this.type === "Vilao" || this.type === "Villain Nemesis" || this.type === "Vilão Nêmesis") {
                spriteName = "unity villain";
            }
        } else if (this.variant === "Transformed") {
            if (this.type === "Hero" || this.type === "Herói" || this.type === "Heroi") {
                spriteName = "Hero transform";
            } else if (this.type === "Villain" || this.type === "Vilão" || this.type === "Vilao" || this.type === "Villain Nemesis" || this.type === "Vilão Nêmesis") {
                spriteName = "Villain transform";
            }
        } else if (this.variant === "MC Transform") {
            if (this.type === "Hero") {
                spriteName = "MC Transform Hero";
            } else if (this.type === "Herói" || this.type === "Heroi") {
                spriteName = "MC Transform Herói";
            }
        } else if (this.variant === "Base transform") {
            if (this.type === "Hero" || this.type === "Herói" || this.type === "Heroi") {
                spriteName = "hero transf";
            } else if (this.type === "Villain" || this.type === "Vilão" || this.type === "Vilao" || this.type === "Villain Nemesis" || this.type === "Vilão Nêmesis") {
                spriteName = "villain transf";
            }
        } else if (this.variant.indexOf("Bribe") === 0 && !this.oversized) {
            const lvl = this.variant.split(" ")[1];
            if (this.type === "Hero") {
                spriteName = `hero bribe ${lvl}`;
            } else if (this.type === "Herói" || this.type === "Heroi") {
                spriteName = `herói suborno ${lvl}`;
            } else if (this.type === "Villain" || this.type === "Villain Nemesis") {
                spriteName = `villain bribe ${lvl}`;
            } else if (this.type === "Vilão" || this.type === "Vilao" || this.type === "Vilão Nêmesis") {
                spriteName = `vilão suborno ${lvl}`;
            }
        } else {
            backgroundType = this.type;
            if (this.type === "Villain Nemesis") backgroundType = "Villain";
            if (this.type === "Vilão Nêmesis") backgroundType = "Vilão";

            if (this.variant === "Super Hero" || this.variant === "Super-Villain" || this.oversized) {
                if (this.type === "Hero" || this.type === "Villain" || this.type === "Herói" || this.type === "Vilão" || this.type === "Heroi" || this.type === "Villain Nemesis" || this.type === "Vilão Nêmesis") {
                    let effectiveType = this.type;
                    if (effectiveType === "Villain Nemesis") effectiveType = "Villain";
                    if (effectiveType === "Vilão Nêmesis") effectiveType = "Vilão";
                    backgroundType = `Super-${effectiveType}`;
                }
            }
            if (this.oversized) {
                backgroundType = `Oversized-${backgroundType}`;
            }
            spriteName = backgroundType.replace(" ", "-").toLowerCase();
            spriteName = spriteName.replace("herói", "heroi");
        }

        newSprite(spriteName, this.container);

        if ((this.variant === "Super Hero" || this.variant === "Super-Villain") && !this.oversized) {
            // draw a black box behind the text
            const graphics = new PIXI.Graphics();
            graphics.beginFill(0x000000); // black
            graphics.drawRect(0, 719, 750, 224);
            graphics.endFill();
            this.container.addChild(graphics);
        }
    }

    /**
     * Renders the logo part of the card
     */
    private renderLogo(): void {
        if (!this.logoURL) {
            return;
        }

        const maxLogoWidth = 175;
        const maxLogoHeight = 175;
        const logoSprite = newSprite(this.logoURL, this.container);
        let bounds = logoSprite.getBounds();

        let scale = 1;
        if (bounds.width > maxLogoWidth) {
            scale = Math.min(scale, maxLogoWidth / bounds.width);
        }
        if (bounds.height > maxLogoHeight) {
            scale = Math.min(scale, maxLogoHeight / bounds.height);
        }

        if (this.logoScale) {
            let finalScale = this.logoScale;
            
            if (!this.oversized) {
                finalScale *= 0.8;
            }
            scale *= finalScale;
        }

        let x = 724;
        let y = 26;
        if (this.oversized) {
            x = CARD_MAX_WIDTH - 30;
            y = 25;
        }

        bounds = logoSprite.getLocalBounds();
        logoSprite.scale.set(scale, scale);
        logoSprite.pivot.x = bounds.width;
        logoSprite.position.set(x, y);
    }

    /**
     * Renders the name part of the card
     */
    private renderName(): void {
        let x = 45;
        let y = 48;
        if (this.oversized) {
            x = 53;
            y = 55;
        }

        const nameContainer = new PIXI.Container();
        const fullText = this.name.toUpperCase();
        const parts = fullText.split(/(\*[^*]+\*)/g);

        let currentX = 0;

        for (const part of parts) {
            if (part === "") { continue; }

            let textPart = part;
            const style = this.getStyle("name");
            let yOffset = 0;

            if (part.startsWith("*") && part.endsWith("*")) {
                textPart = part.substring(1, part.length - 1);
                const originalSize = Number(style.fontSize);
                style.fontSize = originalSize * 0.65;
                style.dropShadowDistance = Number(style.dropShadowDistance) * 0.65;
                style.letterSpacing = Number(style.letterSpacing) * 0.65;
                yOffset = (originalSize - Number(style.fontSize)) * 0.6;
            }

            const textObj = new PIXI.Text(textPart, style);
            textObj.x = currentX;
            textObj.y = yOffset;

            nameContainer.addChild(textObj);
            currentX += textObj.width;
        }

        nameContainer.position.set(x, y);
        nameContainer.scale.y *= 0.75;
        nameContainer.scale.x *= 0.96;
        nameContainer.skew.x = -0.265;

        let maxWidth = (this.oversized ? 900 : 750) - x - 20;
        if (this.logoURL) {
            const logoLeft = this.oversized ? 860 : 720;
            maxWidth = logoLeft - x;
        }

        if (nameContainer.width > maxWidth) {
            const scale = maxWidth / nameContainer.width;
            nameContainer.scale.x *= scale;
            nameContainer.scale.y *= scale;
        }

        this.container.addChild(nameContainer);
    }

    /**
     * Renders the type part of the card (text, not background)
     */
    private renderType(): void {
        if (this.oversized) {
            return;
        }

        let text = cardTypeTranslations[this.type] || this.type;
        text = text.toUpperCase();
        if (this.typePrefix) {
            text = `${this.typePrefix} ${text}`;
        }
        const cardTypeText = new PIXI.Text(text, this.getStyle("type"));
        cardTypeText.x = 45;
        cardTypeText.y = 666;

        cardTypeText.scale.y *= 0.75;
        cardTypeText.scale.x *= 0.96;
        cardTypeText.skew.x = -0.265;
        this.container.addChild(cardTypeText);
    }

    /**
     * Renders the sub type text part of the card
     */
    private renderSubType(): void {
        if (!this.subtype) {
            return;
        }

        let x = 710;
        let y = 705;
        if (this.oversized) {
            x = 900 - 39;
            y = 950;
        }

        const style = this.getStyle("subtype");
        style.fill = "#000000";
        style.stroke = "#ffffff";
        style.strokeThickness = 8;

        const subtypeText = new PIXI.Text(
            this.subtype.toUpperCase(),
            style,
        );

        subtypeText.scale.y *= 0.75;
        subtypeText.scale.x *= 0.96;
        subtypeText.skew.x = -0.265;
        subtypeText.pivot.set(subtypeText.width, subtypeText.height);
        subtypeText.position.set(x, y);
        this.container.addChild(subtypeText);
    }

    /**
     * Renders the cost part of the card
     */
    private renderCost(): void {
        if (this.oversized) {
            return;
        }

        newSprite("background-cost", this.container);

        const costString = String(this.cost);
        const hasAsterisk = costString.indexOf("*") > -1;
        const mainCost = costString.replace(/\*/g, "");

        const renderText = (text: string, x: number, y: number, scale: number, alignLeft: boolean) => {
            const style = this.getStyle("cost");
            style.fontSize = Number(style.fontSize) * scale;
            style.strokeThickness = Number(style.strokeThickness) * scale;

            const backText = new PIXI.Text(text, style);
            backText.pivot.set(alignLeft ? 0 : backText.width / 2, backText.height / 2);
            backText.position.set(x, y);
            this.container.addChild(backText);

            const frontStyle = style.clone();
            frontStyle.stroke = "#ffffff";
            frontStyle.strokeThickness = 10 * scale;

            const frontText = new PIXI.Text(text, frontStyle);
            frontText.pivot.set(alignLeft ? 0 : frontText.width / 2, frontText.height / 2);
            frontText.position.set(x, y);
            this.container.addChild(frontText);

            return backText;
        };

        if (hasAsterisk && mainCost.length > 0) {
            // Render Number (Centered)
            const mainText = renderText(mainCost, 641, 958, 1, false);

            // Render Asterisk (Smaller, to the right)
            const asteriskX = 641 + (mainText.width / 2) - 15;
            const asteriskY = 958 - 25;
            renderText("*", asteriskX, asteriskY, 0.6, true);
        } else {
            // Normal render
            renderText(costString, 641, 958, 1, false);
        }
    }

    /**
     * Renders the victory points part of the card
     */
    private renderVP(): void {
        if (this.oversized) {
            return;
        }

        const vpString = String(this.victoryPoints);
        const isNumber = !isNaN(Number(vpString)) && vpString.trim() !== "";
        const numVal = Number(vpString);

        const vpSign = (isNumber && numVal < 0) ? "negative" : "normal";
        newSprite(`background-vp-${vpSign}`, this.container);

        if (vpString === "*") {
            newSprite("vp-variable", this.container);
            return;
        }

        const scalar = 2;
        const vpStyle = this.getStyle("vp");

        if (isNumber && numVal < 0) {
            vpStyle.stroke = "#9dcd4e"; // green outline for negative VPs
        }

        vpStyle.fontSize = Number(vpStyle.fontSize) * scalar;
        vpStyle.strokeThickness = Number(vpStyle.strokeThickness) * scalar;

        let textToRender = vpString;

        if (isNumber) {
            textToRender = String(Math.abs(numVal));
        } else if (vpString.toUpperCase() === "YOU WIN") {
            textToRender = "YOU\nWIN";
            vpStyle.fontSize = 35 * scalar;
            vpStyle.lineHeight = 32 * scalar;
            vpStyle.align = "center";
        } else if (vpString.toUpperCase() === "VOCÊ VENCEU") {
            textToRender = "VOCÊ\nVENCEU";
            vpStyle.fontSize = 28 * scalar;
            vpStyle.lineHeight = 25 * scalar;
            vpStyle.align = "center";
        }

        const vpText = new PIXI.Text(textToRender, vpStyle);
            vpText.scale.y *= 0.75 / scalar;
            vpText.scale.x *= 1 / scalar;

            const bounds = vpText.getLocalBounds();
            vpText.pivot.set(bounds.width / 2, bounds.height / 2);
            vpText.position.set(88, 982);
            this.container.addChild(vpText);
    }

    /**
     * Renders the text part of the card
     */
    private renderText(): void {
        let formattedText = this.formatText();

        formattedText = replaceAll(formattedText, "[b]", wrapStyledTextCharacters.boldStart);
        formattedText = replaceAll(formattedText, "[/b]", wrapStyledTextCharacters.boldEnd);
        formattedText = replaceAll(formattedText, "[i]", wrapStyledTextCharacters.italicStart);
        formattedText = replaceAll(formattedText, "[/i]", wrapStyledTextCharacters.italicEnd);

        const vpCircle = new PIXI.Circle(603, 230, 70);
        const collisions = [];
        let maxWidth = 750;
        let maxHeight = 205;
        let x = 29;
        let y = 725;
        if (this.oversized) {
            y = 974;
            maxWidth = 910;
            maxHeight = 155;
        }
        else {
            collisions.push(vpCircle);
        }

        let textWidth = maxWidth - x * 2;
        if ((this.subtype && (this.subtype.toLowerCase() === "unity" || this.subtype.toLowerCase() === "união")) || this.variant === "Unity") {
            x = 100;
            textWidth = maxWidth - x - 29;
        }

        if (this.variant && this.variant.indexOf("lvl") !== -1 && !this.oversized) {
            y += 10;
            maxHeight -= 10;
            maxHeight -= 30;
        }

        if (this.variant && this.variant.indexOf("Bribe") === 0 && !this.oversized) {
            y += 56;
            maxHeight -= 56;
        }

        if (this.variant === "Transformed" && !this.oversized) {
            y += 10;
            maxHeight -= 10;
        }

        const style = this.getStyle("text");
        if ((this.variant === "Super Hero" || this.variant === "Super-Villain" || this.variant === "Impossible" || this.variant === "Transformed" || this.variant.indexOf("Hero lvl") === 0 || this.variant.indexOf("Villain lvl") === 0) && !this.oversized) {
            style.fill = "#ffffff";
        }

        if (this.preferredTextSize > 0) {
            style.fontSize = this.preferredTextSize;
        } else {
            style.fontSize = 52;
            const len = this.text.length;
            if (len < 35) {
                style.fontSize = 52;
            } else if (len < 60) {
                style.fontSize = 44;
            } else {
                style.fontSize = 38;
            }
        }

        const textContainer = autoSizeAndWrapStyledText(
            formattedText,
            textWidth,
            maxHeight, style,
            1,
            collisions,
            this.oversized,
            this.oversized,
        );

        const textGroup = new PIXI.Container();
        // O grupo de texto será posicionado em (0, y) porque o fundo precisa começar em x=0.
        textGroup.position.set(0, y);

        // Flatten text nodes to find position
        const textNodes: {node: PIXI.DisplayObject, text: string, y: number, height: number}[] = [];
        const extractTextNodes = (container: PIXI.Container, currentY: number) => {
            if (!container.children) { return; }
            for (const child of container.children) {
                if (child instanceof PIXI.Text || (child as any).text) {
                    textNodes.push({
                        node: child,
                        text: (child as any).text,
                        y: currentY + child.y,
                        height: (child as any).height,
                    });
                } else if (child instanceof PIXI.Container) {
                    extractTextNodes(child, currentY + child.y);
                }
            }
        };
        extractTextNodes(textContainer, 0);

        const cleanCharToNode: typeof textNodes = [];
        let cleanFullText = "";

        for (const node of textNodes) {
            const str = node.text;
            for (let i = 0; i < str.length; i++) {
                const char = str[i];
                if (char !== " " && char !== "\n" && char !== "\t") {
                    cleanFullText += char;
                    cleanCharToNode.push(node);
                }
            }
        }

        const upperCleanText = cleanFullText.toUpperCase();

        for (const config of Card.highlightConfigs) {
            let minY = Infinity;
            let maxY = -Infinity;
            let found = false;

            for (const phrase of config.phrases) {
                const cleanPhrase = phrase.replace(/\s/g, "").toUpperCase();
                const idx = upperCleanText.indexOf(cleanPhrase);

                if (idx !== -1) {
                    found = true;
                    const endIdx = idx + cleanPhrase.length;
                    for (let i = idx; i < endIdx; i++) {
                        if (i < cleanCharToNode.length) {
                            const node = cleanCharToNode[i];
                            if (node.y < minY) { minY = node.y; }
                            if (node.y + node.height > maxY) { maxY = node.y + node.height; }

                            if (node.node instanceof PIXI.Text) {
                                const style = node.node.style.clone();
                                style.fill = "#000000";
                                node.node.style = style;
                            }
                        }
                    }
                }
            }

            if (found && minY !== Infinity) {
                const bg = new PIXI.Graphics();
                bg.beginFill(config.color);
                bg.drawRect(0, minY - 10, this.pxWidth, maxY - minY + 3);
                bg.endFill();
                textGroup.addChild(bg);
            }
        }

        // textContainer deve ser posicionado dentro do textGroup.
        // Sua posição relativa à carta é (x, y).
        // Como textGroup está em (0, y), a posição do textContainer dentro do textGroup deve ser (x, 0).
        textContainer.position.set(x, 0);
        textGroup.addChild(textContainer);

        this.container.addChild(textGroup);
    }

    /**
     * Renders the set part of the card
     * @param copyright the rendered copyright element to position from
     * @returns the rendered set element for future renders to position off
     */
    private renderSet(copyright: PIXI.Container): PIXI.Container {
        if (!this.set) {
            return;
        }

        const style = this.getStyle("set");
        style.fill = this.setTextColor || "#ffffff";
        const set = new PIXI.Text(this.set.toUpperCase(), style);

        set.scale.y *= 0.75;
        set.pivot.set(set.width, set.height);
        if (this.oversized) {
            // note these and other numbers were found via pixel coordinates
            // on the photo shop template
            set.position.x = copyright.x - copyright.width - 16;
            set.position.y = 1171 - set.height;
        }
        else {
            set.position.set(550, 934);
            if (this.variant === "MC Transform") {
                set.position.y += 50;
            }
        }

        // now draw the background
        const xPad = 4;
        const topPad = 3;
        const bottomPad = 4;
        const backgroundColor = (this.setBackgroundColor || "#000000");
        const graphics = new PIXI.Graphics();
        graphics.beginFill(parseInt(backgroundColor.replace(/^#/, ""), 16));
        graphics.drawRoundedRect(
            set.x - set.width - xPad,
            set.y - set.height - topPad,
            set.width + xPad * 2,
            set.height + bottomPad * 2,
            8, // border radius
        );
        graphics.endFill();

        this.container.addChild(graphics);
        this.container.addChild(set);

        return set;
    }

    /**
     * Renders the copyright part of the card
     * @returns the copyright pixi object rendered
     */
    private renderCopyright(): PIXI.Container {
        let maxWidth = 332;
        let x = 223;
        let y = 941;
        if (this.oversized) {
            maxWidth = 182;
            x = 900 - 37;
            y = 1136;
        } else if (this.variant === "MC Transform") {
            y += 50;
        }

        const style = this.getStyle("copyright");
        if ((this.variant === "Super Hero" || this.variant === "Super-Villain" || this.variant === "Impossible" || this.variant === "Transformed" || this.variant.indexOf("Hero lvl") === 0 || this.variant.indexOf("Villain lvl") === 0) && !this.oversized) {
            style.fill = "#ffffff";
        }

        const copyright = wrapStyledText(`©${this.copyright}`, maxWidth, style);

        if (this.oversized) {
            copyright.pivot.x = copyright.width;
        }
        else {
            copyright.pivot.y = copyright.height;
        }

        copyright.position.set(x, y);
        this.container.addChild(copyright);
        return copyright;
    }

    /**
     * Renders the legal part of the card
     * @param set the already rendered set to position off
     * @param copyright the already rendered copyright to position off
     */
    private renderLegal(set: PIXI.Container, copyright: PIXI.Container): void {
        let maxWidth = 332;
        let x = 223;
        let y = 954;
        const style = this.getStyle("legal");
        let legal: PIXI.Container;
        if (this.oversized) {
            maxWidth = 824;
            x = 37;
            y = 1136;

            if (set) {
                maxWidth -= set.width + 16;
            }
            if (copyright) {
                maxWidth -= copyright.width + 16;
            }

            legal = autoSizeAndWrapStyledText(
                this.legal,
                maxWidth,
                Number(style.fontSize) * 2,
                style,
                0.25,
            );
        }
        else {
            // no need to auto size on none oversized cards
            if (this.variant === "MC Transform") {
                y += 50;
            }
            legal = wrapStyledText(
                this.legal,
                maxWidth,
                this.getStyle("legal"),
            );
        }

        if (legal) {
            legal.position.set(x, y);
            this.container.addChild(legal);
        }
    }

    /**
     * Renders the rounded corners part of the card
     */
    private renderRoundedCorners(): void {
        if (!this.roundCorners) {
            return;
        }

        const borderRadius = this.oversized
            ? 45
            : 37;

        const bleedMask = new PIXI.Graphics();
        bleedMask.beginFill(0, 1);
        bleedMask.drawRoundedRect(
            0,
            0,
            this.pxWidth,
            this.pxHeight,
            borderRadius,
        );
        bleedMask.endFill();
        this.container.addChild(bleedMask);
        this.container.mask = bleedMask;
    }
}
