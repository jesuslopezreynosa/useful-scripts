/**
 * Generates a Ublock Origin / AdGuard / ABP compatible filter list for blocking HTML elements with certain terms.
 * I mainly use this to block certain terms (i.e. AI, Politics) from appearing on news sites and social websites
 * 
 * How to use
 * ==========
 * Make sure Node.js / NPM is installed
 * `cd` into the directory with this file (the `package.json` file is necessary)
 * Run `npm run setup` or `npm install`
 * Update the `DOMAIN_FILTERS` and `TERMS` variables in this file to add terms and other selectors to create filters for
 * To generate, run `npm run generate` or `npx ts-node generateBlockists.ts`
 *  =>  Generated output will be put in a file in the same directory called `generatedList.txt`
 * 
 * Example of output with the default entries
 * ==========================================
 * old.reddit.com##.link.thing:has(.title:has-text(term Example))
 * electrek.co##article:has(.article__title-link:has-text(term Example))
 * www.theverge.com##.duet--content-cards--content-card:has-text(term Example)
 * www.theregister.com##article:has(.article_text_elements:has-text(term Example))
 * arstechnica.com##.article:has(a:has-text(term Example))
 */
import { writeFileSync } from 'node:fs';

type Filter = {
    prefix: string;
    suffix: string;
}

const DOMAIN_FILTERS: Array<Filter> = [
    { prefix: 'old.reddit.com##.link.thing:has(.title:has-text(', suffix: '))' },
    { prefix: 'electrek.co##article:has(.article__title-link:has-text(', suffix: '))' },
    { prefix: 'www.theverge.com##.duet--content-cards--content-card:has-text(', suffix: ')' },
    { prefix: 'www.theregister.com##article:has(.article_text_elements:has-text(', suffix: '))' },
    { prefix: 'arstechnica.com##.article:has(a:has-text(', suffix: '))' },
];

// Add terms to filter, is case-sensitive
const TERMS: string[] = [
    'term Example'
];

function generateBlocklistFromTerms(baseFilterPrefix: string, baseFilterSuffix: string, terms: string[]): string[] {
    const GENERATED_LIST: string[] = [];

    if (baseFilterPrefix && baseFilterSuffix && terms != undefined && terms != null && terms.length > 0) {
        for (const TERM of terms) {
            if (TERM.length > 0) {
                GENERATED_LIST.push(`${ baseFilterPrefix }${ TERM.trim() }${ baseFilterSuffix }`);
            }
        }
    }

    return GENERATED_LIST;
}

function generateAllDomainFilters(domainFilters: Array<Filter>, terms: string[]): string[] {
    const GENERATED_LIST: string[] = [];

    if (domainFilters && domainFilters.length > 0 && terms && terms.length > 0) {
        for (const FILTER of domainFilters) {
            GENERATED_LIST.push(...generateBlocklistFromTerms(FILTER.prefix, FILTER.suffix, terms));
        }
    }

    return GENERATED_LIST;
}

const GENERATED_FILTERS = generateAllDomainFilters(DOMAIN_FILTERS, TERMS);
writeFileSync('./generatedList.txt', GENERATED_FILTERS.join('\n'));