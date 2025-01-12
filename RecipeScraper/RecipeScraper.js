const { chromium } = require('playwright');
const { exec } = require('child_process');
const { promisify } = require('util');
const execAsync = promisify(exec);
const fs = require('fs').promises;
const path = require('path');
const sqlite3 = require('sqlite3').verbose();
const { open } = require('sqlite');

// Define database path in user's home directory
const DB_PATH = path.join(process.env.HOME, 'recipes.db');

class Sites {
    static BBC_GOOD_FOOD = {
        id: 'bbcgoodfood.com',
        name: 'BBC Good Food'
    };
    
    static BBC_FOOD = {
        id: 'bbc.co.uk/food',
        name: 'BBC Food'
    };
    
    static TASTEMADE = {
        id: 'tastemade.com',
        name: 'Tastemade'
    };
    
    static NYONYA_COOKING = {
        id: 'nyonyacooking.com',
        name: 'Nyonya Cooking'
    };

    static NYT_COOKING = {
        id: 'cooking.nytimes.com',
        name: 'NYT Cooking'
    };

    static HAPPY_FOODIE = {
        id: 'thehappyfoodie.co.uk',
        name: 'The Happy Foodie'
    };

    static GOOD_TO = {
        id: ['goodto.com', 'goodtoknow.co.uk'],
        name: 'Good To'
    };

    static TIP_HERO = {
        id: 'tiphero.com',
        name: 'Tip Hero'
    };

    static FOOD_COM = {
        id: 'food.com',
        name: 'Food.com'
    };

    static JANES_PATISSERIE = {
        id: 'janespatisserie.com',
        name: 'Janes Patisserie'
    };

    static MAKAN = {
        id: 'makan.ch',
        name: 'Makan'
    };

    static MY_THIRTY_SPOT = {
        id: 'mythirtyspot.com',
        name: 'My Thirty Spot'
    };

    static HEMSLEY = {
        id: 'hemsleyandhemsley.com',
        name: 'Hemsley and Hemsley'
    };

    static DONAL_SKEHAN = {
        id: 'donalskehan.com',
        name: 'Donal Skehan'
    };

    static NATASHAS_KITCHEN = {
        id: 'natashaskitchen.com',
        name: 'Natashas Kitchen'
    };

    static JOY_OF_BAKING = {
        id: 'joyofbaking.com',
        name: 'Joy of Baking'
    };

    static ALL_RECIPES = {
        id: ['allrecipes.com', 'allrecipes.co.uk'],
        name: 'AllRecipes'
    };

    static VISIT_CROATIA = {
        id: 'visit-croatia.co.uk',
        name: 'Visit Croatia'
    };

    static GENERIC = {
        id: 'generic',
        name: 'Generic Recipe Site'
    };

    static ALL = [
        Sites.BBC_GOOD_FOOD,
        Sites.BBC_FOOD,
        Sites.TASTEMADE,
        Sites.NYONYA_COOKING,
        Sites.NYT_COOKING,
        Sites.HAPPY_FOODIE,
        Sites.GOOD_TO,
        Sites.TIP_HERO,
        Sites.FOOD_COM,
        Sites.JANES_PATISSERIE,
        Sites.MAKAN,
        Sites.MY_THIRTY_SPOT,
        Sites.HEMSLEY,
        Sites.DONAL_SKEHAN,
        Sites.NATASHAS_KITCHEN,
        Sites.JOY_OF_BAKING,
        Sites.ALL_RECIPES,
        Sites.VISIT_CROATIA
    ];

    static isSupportedSite(url) {
        return Sites.ALL.some(site => {
            if (Array.isArray(site.id)) {
                return site.id.some(id => url.includes(id));
            }
            return url.includes(site.id);
        });
    }

    static getSiteName(url) {
        const site = Sites.ALL.find(site => {
            if (Array.isArray(site.id)) {
                return site.id.some(id => url.includes(id));
            }
            return url.includes(site.id);
        });
        return site ? site.name : 'Unknown';
    }

    static isBBC(url) {
        return url.includes(Sites.BBC_GOOD_FOOD.id) || url.includes(Sites.BBC_FOOD.id);
    }

    static isTastemade(url) {
        return url.includes(Sites.TASTEMADE.id);
    }

    static isNyonyaCooking(url) {
        return url.includes(Sites.NYONYA_COOKING.id);
    }

    static isNYTCooking(url) {
        return url.includes(Sites.NYT_COOKING.id);
    }

    static isHappyFoodie(url) {
        return url.includes(Sites.HAPPY_FOODIE.id);
    }

    static isGoodTo(url) {
        return url.includes(Sites.GOOD_TO.id);
    }

    static isTipHero(url) {
        return url.includes(Sites.TIP_HERO.id);
    }

    static isFoodCom(url) {
        return url.includes(Sites.FOOD_COM.id);
    }

    static isJanesPatisserie(url) {
        return url.includes(Sites.JANES_PATISSERIE.id);
    }

    static isMakan(url) {
        return url.includes(Sites.MAKAN.id);
    }

    static isMyThirtySpot(url) {
        return url.includes(Sites.MY_THIRTY_SPOT.id);
    }

    static isHemsley(url) {
        return url.includes(Sites.HEMSLEY.id);
    }

    static isDonalSkehan(url) {
        return url.includes(Sites.DONAL_SKEHAN.id);
    }

    static isNatashasKitchen(url) {
        return url.includes(Sites.NATASHAS_KITCHEN.id);
    }

    static isJoyOfBaking(url) {
        return url.includes(Sites.JOY_OF_BAKING.id);
    }

    static isAllRecipes(url) {
        return url.includes(Sites.ALL_RECIPES.id);
    }

    static isVisitCroatia(url) {
        return url.includes(Sites.VISIT_CROATIA.id);
    }

    static async tryGenericScraper(page) {
        console.log('Attempting generic recipe scraping...');
        let ingredients = { main: [], garnishes: [] };
        let method = [];
        let nutrition = null;

        try {
            // First check for tabbed ingredient content
            try {
                // Try to find ingredients in tab content
                const tabContentSelectors = [
                    '#metric p span, #metric p',  // Metric tab content
                    '#us p span, #us p',         // US tab content if metric fails
                    '.tab-pane.active p span, .tab-pane.active p',  // Any active tab content
                    '.tab-content p span, .tab-content p'  // Any tab content
                ];

                for (const selector of tabContentSelectors) {
                    const elements = await page.$$(selector);
                    if (elements.length > 0) {
                        console.log(`Found ingredients in tab content using selector: ${selector}`);
                        for (const el of elements) {
                            const text = await el.textContent();
                            const cleaned = text.trim()
                                .replace(/\s+/g, ' ')
                                .replace(/\n/g, ' ');
                            
                            if (cleaned && 
                                !cleaned.toLowerCase().includes('method') && 
                                !cleaned.toLowerCase().includes('direction') && 
                                !cleaned.toLowerCase().includes('step') &&
                                !cleaned.match(/^(us|metric)$/i) &&
                                cleaned.length > 1) {
                                ingredients.main.push(cleaned);
                            }
                        }
                        if (ingredients.main.length > 0) {
                            break;
                        }
                    }
                }
            } catch (error) {
                console.log('No tabbed ingredient content found, trying standard selectors');
            }

            // If no ingredients found in tabs, try standard selectors
            if (ingredients.main.length === 0) {
                // Look for ingredients section using common patterns
                const ingredientSelectors = [
                    // Specific ingredient list selectors
                    'ul.recipe-ingredients li',
                    'ul.ingredients-list li',
                    '.recipe-ingredients li',
                    '.ingredients-list li',
                    '[itemprop="recipeIngredient"]',
                    // Generic ingredient section selectors
                    'h2:has-text("Ingredients") ~ ul:first-of-type li',
                    'h3:has-text("Ingredients") ~ ul:first-of-type li',
                    'h4:has-text("Ingredients") ~ ul:first-of-type li',
                    'div[class*="ingredient" i] li',
                    'section[class*="ingredient" i] li',
                    '*:has-text("Ingredients") ~ ul:first-of-type li',
                    '*[class*="ingredient-list" i] li',
                    // Fallback text-based selectors
                    'p:has-text("Ingredients") ~ p:not(:has-text("Method")):not(:has-text("Direction")):not(:has-text("Step"))',
                    '*:has-text("Ingredients") ~ p:not(:has-text("Method")):not(:has-text("Direction")):not(:has-text("Step"))'
                ];

                // First try to find and handle unit toggle buttons if they exist
                try {
                    const metricButton = await page.$('button:has-text("Metric")');
                    if (metricButton) {
                        await metricButton.click();
                        await page.waitForTimeout(500); // Wait for toggle to take effect
                    }
                } catch (error) {
                    // Ignore if no metric button found
                }

                let foundIngredients = false;
                for (const selector of ingredientSelectors) {
                    try {
                        const elements = await page.$$(selector);
                        if (elements.length > 0) {
                            console.log(`Found ingredients using selector: ${selector}`);
                            for (const el of elements) {
                                const text = await el.textContent();
                                const cleaned = text.trim()
                                    .replace(/\s+/g, ' ')
                                    .replace(/\n/g, ' ');
                                
                                // Skip navigation/category elements and empty lines
                                if (cleaned && 
                                    !cleaned.toLowerCase().includes('method') && 
                                    !cleaned.toLowerCase().includes('direction') && 
                                    !cleaned.toLowerCase().includes('step') &&
                                    !cleaned.toLowerCase().includes('recipe') &&
                                    !cleaned.toLowerCase().includes('dessert') &&
                                    !cleaned.toLowerCase().includes('baking') &&
                                    !cleaned.toLowerCase().includes('snack') &&
                                    !cleaned.match(/^(us|metric)$/i) && // Skip unit toggle text
                                    !cleaned.match(/^(you'll need|equipment|utensils):/i) && // Skip equipment headers
                                    cleaned.length > 1) { // Skip single characters
                                    
                                    // Check if it's an equipment/utensil line
                                    if (!cleaned.toLowerCase().includes('tin') &&
                                        !cleaned.toLowerCase().includes('pan') &&
                                        !cleaned.toLowerCase().includes('bowl') &&
                                        !cleaned.toLowerCase().includes('paper')) {
                                        ingredients.main.push(cleaned);
                                    }
                                }
                            }
                            if (ingredients.main.length > 0) {
                                foundIngredients = true;
                                break;
                            }
                        }
                    } catch (error) {
                        continue;
                    }
                }

                // If no ingredients found with selectors, try text block approach
                if (!foundIngredients) {
                    try {
                        const content = await page.evaluate(() => document.body.textContent);
                        const ingredientsMatch = content.match(/ingredients:?([\s\S]*?)(?:directions|method|steps|preparation|instructions|you'll need|equipment|$)/i);
                        if (ingredientsMatch && ingredientsMatch[1]) {
                            const ingredientsList = ingredientsMatch[1]
                                .split('\n')
                                .map(line => line.trim())
                                .filter(line => 
                                    line.length > 0 && 
                                    !line.toLowerCase().includes('direction') && 
                                    !line.toLowerCase().includes('method') &&
                                    !line.match(/^(us|metric)$/i) &&
                                    !line.match(/^(you'll need|equipment|utensils):/i));
                            ingredients.main = ingredientsList;
                            console.log('Found ingredients in text content');
                        }
                    } catch (error) {
                        console.log('Error extracting ingredients from text:', error.message);
                    }
                }
            }

            // Look for method/steps/directions section using common patterns
            const methodSelectors = [
                'h2:has-text("Method") ~ ol li',
                'h2:has-text("Steps") ~ ol li',
                'h2:has-text("Directions") ~ ol li',
                'h2:has-text("Preparation") ~ ol li',
                'h3:has-text("Method") ~ ol li',
                'h3:has-text("Steps") ~ ol li',
                'h3:has-text("Directions") ~ ol li',
                'h3:has-text("Preparation") ~ ol li',
                'div[class*="method" i] li',
                'div[class*="direction" i] li',
                'div[class*="preparation" i] li',
                'section[class*="method" i] li',
                '*:has-text("Method") ~ ol li',
                '*:has-text("Steps") ~ ol li',
                '*:has-text("Directions") ~ ol li',
                '*[class*="method-steps" i] li',
                // Add paragraph-based selectors
                'h2:has-text("Method") ~ p',
                'h2:has-text("Steps") ~ p',
                'h2:has-text("Directions") ~ p',
                'h3:has-text("Method") ~ p',
                'h3:has-text("Steps") ~ p',
                'h3:has-text("Directions") ~ p'
            ];

            for (const selector of methodSelectors) {
                try {
                    const elements = await page.$$(selector);
                    if (elements.length > 0) {
                        console.log(`Found method steps using selector: ${selector}`);
                        const steps = await Promise.all(elements.map(async el => {
                            const text = await el.textContent();
                            return text.trim()
                                .replace(/\s+/g, ' ')
                                .replace(/\n/g, ' ');
                        }));
                        // Filter out empty steps and those that look like ingredients
                        method = steps.filter(step => 
                            step.length > 0 && 
                            !step.match(/^\d+(\.\d+)?\s*(cup|tbsp|tsp|oz|g|ml|pound|kg)/i)
                        );
                        if (method.length > 0) {
                            break;
                        }
                    }
                } catch (error) {
                    continue;
                }
            }

            // If no method found, try looking for a text block with directions/method
            if (method.length === 0) {
                try {
                    const content = await page.evaluate(() => document.body.textContent);
                    const methodMatch = content.match(/(?:directions|method|steps|preparation|instructions):?([\s\S]*?)(?:nutrition|notes|tips|$)/i);
                    if (methodMatch && methodMatch[1]) {
                        method = methodMatch[1]
                            .split(/\d+\.|(?:\r?\n){2,}/)
                            .map(step => step.trim())
                            .filter(step => step.length > 0 && !step.match(/^\d+(\.\d+)?\s*(cup|tbsp|tsp|oz|g|ml|pound|kg)/i));
                        console.log('Found method steps in text content');
                    }
                } catch (error) {
                    console.log('Error extracting method from text:', error.message);
                }
            }

            // Look for nutrition section using common patterns
            const nutritionSelectors = [
                'h2:has-text("Nutrition") ~ table tr',
                'h2:has-text("Nutrition Information") ~ div',
                'div[class*="nutrition" i] li',
                'section[class*="nutrition" i] li',
                '*:has-text("Nutrition Facts") ~ div',
                '*[class*="nutrition-info" i]',
                // Add paragraph-based selectors
                'h2:has-text("Nutrition") ~ p',
                'h3:has-text("Nutrition") ~ p'
            ];

            for (const selector of nutritionSelectors) {
                try {
                    const elements = await page.$$(selector);
                    if (elements.length > 0) {
                        console.log(`Found nutrition info using selector: ${selector}`);
                        nutrition = {};
                        for (const el of elements) {
                            const text = await el.textContent();
                            // Look for patterns like "label: value" or "label value"
                            const matches = text.match(/([^:0-9]+?)(?::|(?=\d))\s*([0-9.]+[a-zA-Z%\s]*)/g);
                            if (matches) {
                                matches.forEach(match => {
                                    const [label, value] = match.split(/:\s*/);
                                    if (label && value) {
                                        nutrition[label.trim()] = value.trim();
                                    }
                                });
                            }
                        }
                        if (Object.keys(nutrition).length > 0) {
                            break;
                        }
                    }
                } catch (error) {
                    continue;
                }
            }

            console.log(`Generic scraper found: ${ingredients.main.length} ingredients, ${method.length} steps, ${nutrition ? Object.keys(nutrition).length : 0} nutrition items`);

            return {
                ingredients,
                method,
                nutrition
            };
        } catch (error) {
            console.log('Error in generic scraper:', error.message);
            return null;
        }
    }

    static async scrapeGoodTo(page) {
        console.log('Scraping Good To recipe...');
        let ingredients = { main: [], garnishes: [] };
        let method = [];
        let nutrition = {};
        let metadata = {};

        try {
            // Extract metadata (servings, time, etc.)
            const metadataSelectors = {
                'Serves': 'text:has-text("Serves")',
                'Skill': 'text:has-text("Skill")',
                'Preparation Time': 'text:has-text("Preparation Time")',
                'Cooking Time': 'text:has-text("Cooking Time")',
                'Total Time': 'text:has-text("Total Time")'
            };

            for (const [key, selector] of Object.entries(metadataSelectors)) {
                try {
                    const element = await page.$(selector);
                    if (element) {
                        const text = await element.textContent();
                        const value = text.split('\t').pop().trim();
                        metadata[key] = value;
                    }
                } catch (error) {
                    console.log(`Error extracting ${key}:`, error.message);
                }
            }

            // Extract ingredients
            const ingredientSections = await page.$$('h3:has-text("Ingredients") ~ ul li, h2:has-text("Ingredients") ~ ul li');
            if (ingredientSections.length > 0) {
                for (const section of ingredientSections) {
                    const text = await section.textContent();
                    const cleaned = text.trim()
                        .replace(/\s+/g, ' ')
                        .replace(/\n/g, ' ');
                    if (cleaned && !cleaned.toLowerCase().includes('for the')) {
                        ingredients.main.push(cleaned);
                    }
                }
            }

            // Extract method steps
            const methodSteps = await page.$$('h3:has-text("Method") ~ ol li, h2:has-text("Method") ~ ol li');
            if (methodSteps.length > 0) {
                method = await Promise.all(methodSteps.map(async step => {
                    const text = await step.textContent();
                    return text.trim()
                        .replace(/\s+/g, ' ')
                        .replace(/\n/g, ' ');
                }));
            }

            // Extract nutrition information
            const nutritionRows = await page.$$('text:has-text("NUTRITION PER PORTION") ~ table tr');
            for (const row of nutritionRows) {
                try {
                    const cells = await row.$$('td');
                    if (cells.length >= 2) {
                        const label = await cells[0].textContent();
                        const value = await cells[1].textContent();
                        if (label && value) {
                            nutrition[label.trim()] = value.trim();
                        }
                    }
                } catch (error) {
                    continue;
                }
            }

            // If no nutrition found with table, try text-based extraction
            if (Object.keys(nutrition).length === 0) {
                const nutritionText = await page.evaluate(() => {
                    const nutritionSection = document.querySelector('*:has-text("NUTRITION PER PORTION")');
                    return nutritionSection ? nutritionSection.textContent : '';
                });

                if (nutritionText) {
                    const matches = nutritionText.matchAll(/([A-Za-z\s]+)\s+([0-9.]+[A-Za-z\s%]+)/g);
                    for (const match of matches) {
                        if (match[1] && match[2]) {
                            nutrition[match[1].trim()] = match[2].trim();
                        }
                    }
                }
            }

            return {
                ingredients,
                method,
                nutrition,
                metadata
            };
        } catch (error) {
            console.error('Error in Good To scraper:', error);
            return null;
        }
    }
}

// Read recipes from JSON file
async function loadRecipes() {
    try {
        const recipesPath = path.join(__dirname, 'recipes.json');
        const data = await fs.readFile(recipesPath, 'utf8');
        return JSON.parse(data);
    } catch (error) {
        console.error('Error reading recipes.json:', error);
        throw error;
    }
}

async function isSupportedSite(url) {
    return Sites.isSupportedSite(url);
}

async function initializeDatabase() {
    console.log(`Initializing database at: ${DB_PATH}`);
    
    const db = await open({
        filename: DB_PATH,
        driver: sqlite3.Database
    });

    // Create recipes table if it doesn't exist
    await db.exec(`
        CREATE TABLE IF NOT EXISTS recipes (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            url TEXT UNIQUE NOT NULL,
            site TEXT NOT NULL,
            ingredients TEXT NOT NULL,
            method TEXT NOT NULL,
            nutrition TEXT,
            created_at DATETIME DEFAULT CURRENT_TIMESTAMP
        )
    `);

    return db;
}

async function saveRecipe(db, url, recipe) {
    const site = Sites.getSiteName(url);

    try {
        await db.run(`
            INSERT OR REPLACE INTO recipes (url, site, ingredients, method, nutrition)
            VALUES (?, ?, ?, ?, ?)
        `, [
            url,
            site,
            JSON.stringify(recipe.ingredients),
            JSON.stringify(recipe.method),
            recipe.nutrition ? JSON.stringify(recipe.nutrition) : null
        ]);
        
        console.log(`Successfully saved recipe from ${site} to database`);
    } catch (error) {
        console.error('Error saving recipe to database:', error);
        throw error;
    }
}

async function launchChromeWithDebugging() {
    try {
        // Launch Chrome in the background and keep it running
        const chromeProcess = exec(
            '"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" --remote-debugging-port=9222 --no-first-run --no-default-browser-check --user-data-dir=/tmp/chrome-testing',
            {
                detached: true,
                stdio: 'ignore'
            }
        );
        
        // Unref the process so it can run independently
        chromeProcess.unref();
        
        // Wait for Chrome to start and the debugging port to be available
        let attempts = 0;
        while (attempts < 10) {
            try {
                await execAsync('curl -s http://localhost:9222');
                console.log('Chrome debugging port is ready');
                return;
            } catch (error) {
                attempts++;
                await new Promise(resolve => setTimeout(resolve, 1000));
            }
        }
        throw new Error('Failed to confirm Chrome debugging port is ready');
    } catch (error) {
        console.error('Failed to launch Chrome:', error);
        throw error;
    }
}

async function scrapeRecipe(url) {
    let browser = null;
    let page = null;
    let retries = 0;
    const maxRetries = 3;
    
    // Check if we already have the recipe data in the database
    try {
        const db = await initializeDatabase();
        const existingRecipe = await db.get('SELECT * FROM recipes WHERE url = ?', [url]);
        
        if (existingRecipe) {
            const data = {
                ingredients: JSON.parse(existingRecipe.ingredients),
                method: JSON.parse(existingRecipe.method),
                nutrition: existingRecipe.nutrition ? JSON.parse(existingRecipe.nutrition) : null
            };
            
            console.log(`Recipe already exists in database for ${url}`);
            console.log(`Found ${data.ingredients.main.length} ingredients`);
            console.log(`Found ${data.method.length} method steps`);
            if (data.nutrition) {
                console.log(`Found ${Object.keys(data.nutrition).length} nutrition items`);
            }
            
            return data;
        }
    } catch (error) {
        console.log('Error checking database for existing recipe:', error);
    }

    // If we don't have the data, proceed with scraping
    while (retries < maxRetries) {
        try {
            browser = await chromium.connectOverCDP('http://localhost:9222');
            break;
        } catch (error) {
            retries++;
            console.log(`Connection attempt ${retries} failed, launching Chrome...`);
            await launchChromeWithDebugging();
            await new Promise(resolve => setTimeout(resolve, 3000));
        }
    }

    if (!browser) {
        throw new Error('Failed to connect to Chrome after multiple attempts');
    }
    
    try {
        const context = browser.contexts()[0];
        page = await context.newPage();
        
        // Ignore SSL errors
        await page.route('**/*', route => {
            route.continue({
                ignoreHTTPSErrors: true
            });
        });
        
        await page.goto(url, { 
            waitUntil: 'domcontentloaded',
            timeout: 30000,
            ignoreHTTPSErrors: true
        });

        // Detect which site we're on using the Sites class
        const isBBC = Sites.isBBC(url);
        const isTastemade = Sites.isTastemade(url);
        const isNyonyaCooking = Sites.isNyonyaCooking(url);
        const isNYTCooking = Sites.isNYTCooking(url);
        const isHappyFoodie = Sites.isHappyFoodie(url);

        let ingredients, method, nutrition = null;

        if (isNYTCooking) {
            console.log(`Detected ${Sites.NYT_COOKING.name} recipe site`);
            
            // Wait for initial page load
            await page.waitForLoadState('domcontentloaded');
            await new Promise(resolve => setTimeout(resolve, 2000));

            // Extract ingredients
            try {
                // Try multiple selectors for ingredients
                const ingredientSelectors = [
                    '.ingredients_ingredient__VJJH9',
                    '.ingredients_ingredientGroup__jYQJu li',
                    '.pantry--body-long'
                ];

                ingredients = {
                    main: [],
                    garnishes: []
                };

                for (const selector of ingredientSelectors) {
                    const elements = await page.$$(selector);
                    if (elements.length > 0) {
                        console.log(`Found ingredients using selector: ${selector}`);
                        for (const el of elements) {
                            const text = await el.textContent();
                            const cleaned = text.trim()
                                .replace(/\s+/g, ' ')
                                .replace(/\n/g, ' ');
                            if (cleaned) {
                                ingredients.main.push(cleaned);
                            }
                        }
                        break;
                    }
                }

                if (ingredients.main.length === 0) {
                    throw new Error('No ingredients found with any selector');
                }

                console.log(`Found ${ingredients.main.length} ingredients`);
            } catch (error) {
                console.log('Error extracting ingredients:', error.message);
                // Initialize with empty array if extraction fails
                ingredients = { main: [], garnishes: [] };
            }

            // Extract method steps
            try {
                const methodElements = await page.$$('.preparation_stepContent__CFrQM p');
                if (methodElements.length > 0) {
                    method = await Promise.all(methodElements.map(async step => {
                        const text = await step.textContent();
                        return text.trim()
                            .replace(/\s+/g, ' ')
                            .replace(/\n/g, ' ');
                    }));
                    console.log(`Found ${method.length} method steps`);
                } else {
                    throw new Error('No method steps found');
                }
            } catch (error) {
                console.log('Error extracting method steps:', error.message);
                method = [];
            }

            // NYT Cooking doesn't have nutrition info
            nutrition = null;
            console.log('No nutrition data available for NYT Cooking recipes');

            // Only return if we have the minimum required data
            if (ingredients.main.length === 0 || method.length === 0) {
                throw new Error('Failed to extract required recipe data');
            }

            return {
                ingredients,
                method,
                nutrition
            };
        } else if (isNyonyaCooking) {
            console.log(`Detected ${Sites.NYONYA_COOKING.name} recipe site`);
            
            // Wait for initial page load
            await page.waitForLoadState('domcontentloaded');
            await new Promise(resolve => setTimeout(resolve, 2000));

            // Extract ingredients
            try {
                const ingredientElements = await page.$$('.recipe-ingredients dl.row dt, .recipe-ingredients dl.row dd');
                if (ingredientElements.length > 0) {
                    ingredients = {
                        main: [],
                        garnishes: []
                    };

                    for (let i = 0; i < ingredientElements.length; i += 2) {
                        const amount = await ingredientElements[i].textContent();
                        const ingredient = await ingredientElements[i + 1].textContent();
                        ingredients.main.push(`${amount.trim()} ${ingredient.trim()}`);
                    }
                    console.log(`Found ${ingredients.main.length} ingredients`);
                }
            } catch (error) {
                console.log('Error extracting ingredients:', error.message);
            }

            // Extract method steps
            try {
                const methodElements = await page.$$('article.card.shadow-sm.article-body');
                if (methodElements.length > 0) {
                    method = await Promise.all(methodElements.map(async step => {
                        const stepText = await step.$eval('span p', el => el.textContent.trim());
                        return stepText;
                    }));
                    console.log(`Found ${method.length} method steps`);
                }
            } catch (error) {
                console.log('Error extracting method steps:', error.message);
            }

            // Extract nutrition
            try {
                const nutritionElements = await page.$$('.row .col-6.col-md-3');
                if (nutritionElements.length > 0) {
                    nutrition = {};
                    for (const el of nutritionElements) {
                        const label = await el.$eval('.label-sm', node => node.textContent.trim());
                        const value = await el.$eval('div', node => node.textContent.trim());
                        if (label && value) {
                            nutrition[label] = value;
                        }
                    }
                    console.log(`Found ${Object.keys(nutrition).length} nutrition items`);
                }
            } catch (error) {
                console.log('Error extracting nutrition:', error.message);
            }

            return {
                ingredients,
                method,
                nutrition
            };
        } else if (isBBC) {
            console.log('Detected BBC recipe site');
            // Wait for initial page load
            await page.waitForLoadState('domcontentloaded');
            
            // Wait a bit for dynamic content
            await new Promise(resolve => setTimeout(resolve, 2000));
            
            // Extract ingredients using the working selectors
            const ingredientSelectors = url.includes('bbc.co.uk/food') 
                ? ['[data-testid="recipe-ingredients"] .ssrcss-1uix24b-Stack'] // BBC Food
                : ['.ingredients-list__item']; // BBC Good Food

            let ingredientElements = [];
            for (const selector of ingredientSelectors) {
                try {
                    console.log(`Trying ingredient selector: ${selector}`);
                    await page.waitForSelector(selector, { timeout: 5000 });
                    ingredientElements = await page.$$(selector);
                    if (ingredientElements.length > 0) {
                        console.log(`Found ${ingredientElements.length} ingredients with selector: ${selector}`);
                        break;
                    }
                } catch (error) {
                    console.log(`Selector ${selector} not found, trying next...`);
                    continue;
                }
            }

            ingredients = {
                main: await Promise.all(ingredientElements.map(async el => {
                    const mainText = await el.textContent();
                    return mainText.trim()
                        .replace(/\s+/g, ' ') // Replace multiple spaces with single space
                        .replace(/\n/g, ' '); // Replace newlines with spaces
                })),
                garnishes: []
            };

            // Extract method steps using the working selectors
            const methodSelectors = url.includes('bbc.co.uk/food')
                ? ['[data-testid="recipe-method"] .ssrcss-15tc05p-ListItemText p'] // BBC Food
                : ['.method-steps__list-item .editor-content p']; // BBC Good Food - Updated selector

            let methodElements = [];
            for (const selector of methodSelectors) {
                try {
                    console.log(`Trying method selector: ${selector}`);
                    await page.waitForSelector(selector, { timeout: 5000 });
                    methodElements = await page.$$(selector);
                    if (methodElements.length > 0) {
                        console.log(`Found ${methodElements.length} method steps with selector: ${selector}`);
                        break;
                    }
                } catch (error) {
                    console.log(`Selector ${selector} not found, trying next...`);
                    continue;
                }
            }

            method = await Promise.all(methodElements.map(async el => {
                const text = await el.textContent();
                return text.trim()
                    .replace(/\s+/g, ' ') // Replace multiple spaces with single space
                    .replace(/\n/g, ' '); // Replace newlines with spaces
            }));

            // Add debug logging
            console.log('\nIngredients found:', ingredients.main.length);
            console.log('Method steps found:', method.length);

            // Extract nutrition using multiple possible selectors
            const nutritionSelectors = url.includes('bbc.co.uk/food') 
                ? [] // BBC Food doesn't have nutrition info
                : ['.nutrition-list__item']; // BBC Good Food selector

            let nutritionElements = [];
            let nutrition = null;

            if (nutritionSelectors.length > 0) {
                try {
                    // First try to find and click the Nutrition tab
                    console.log('Looking for Nutrition tab...');
                    const nutritionTab = await page.$('button.tabbed-list__tab-button:has-text("Nutrition")');
                    if (nutritionTab) {
                        console.log('Found Nutrition tab, clicking...');
                        await nutritionTab.click();
                        // Wait a moment for content to load
                        await page.waitForTimeout(1000);
                    }

                    // Now try to extract nutrition data
                for (const selector of nutritionSelectors) {
                    try {
                        console.log(`Trying nutrition selector: ${selector}`);
                        await page.waitForSelector(selector, { timeout: 5000 });
                        nutritionElements = await page.$$(selector);
                        if (nutritionElements.length > 0) {
                            console.log(`Found ${nutritionElements.length} nutrition items with selector: ${selector}`);
                            
                            // For BBC Good Food, extract nutrition data
                            nutrition = {};
                            await Promise.all(nutritionElements.map(async el => {
                                const text = await el.textContent();
                                const matches = text.match(/^([^0-9]+?)\s*([0-9.]+(?:g|kcal)?)$/);
                                if (matches) {
                                    const label = matches[1].replace(/\s+/g, ' ').trim();
                                    const value = matches[2].trim();
                                    nutrition[label] = value;
                                }
                            }));

                                if (nutrition && Object.keys(nutrition).length > 0) {
                                    console.log('Nutrition items found:', Object.keys(nutrition).length);
                                } else {
                                    console.log('No nutrition items found in extracted data');
                                }
                            
                            break;
                        }
                    } catch (error) {
                        console.log(`Selector ${selector} not found, trying next...`);
                        continue;
                    }
                }
                } catch (error) {
                    console.log('Error accessing nutrition tab:', error.message);
                }
            }

            // After nutrition extraction loop
            if (!nutrition) {
                console.log('No nutrition data found after trying all selectors');
            }

            return {
                ingredients,
                method,
                nutrition
            };

        } else if (isTastemade) {
            console.log(`Detected ${Sites.TASTEMADE.name} recipe site`);
            // Tastemade selectors
            await page.waitForSelector('#recipe-ingredients', {
                timeout: 30000,
                state: 'attached'
            });

            const ingredientsData = await page.$$eval('#recipe-ingredients h3', async elements => {
                let result = [];
                for (const header of elements) {
                    const section = header.textContent.trim();
                    const items = Array.from(header.nextElementSibling.querySelectorAll('li'))
                        .map(li => li.textContent.trim());
                    
                    if (section === 'Garnishes') {
                        result.garnishes = items;
                    } else {
                        result = result.concat(items);
                    }
                }
                return result;
            });

            ingredients = {
                main: ingredientsData.filter(item => !ingredientsData.garnishes?.includes(item)),
                garnishes: ingredientsData.garnishes || []
            };

            await page.waitForSelector('#recipe-preparation ol li', {
                timeout: 30000,
                state: 'attached'
            });

            method = await page.$$eval('#recipe-preparation ol li',
                elements => elements.map(el => el.textContent.trim())
            );

            console.log('\nIngredients found:', ingredients.main.length + (ingredients.garnishes?.length || 0));
            console.log('Method steps found:', method.length);

            // Extract nutrition data
            let nutrition = null;
            try {
                // Look for and click the nutrition button
                const nutritionButton = await page.$('button:has-text("Nutrition Information")');
                if (nutritionButton) {
                    await nutritionButton.click();
                    await page.waitForSelector('.mb-5.flex.flex-col.divide-y', { timeout: 5000 });

                    // Extract all nutrition items
                    nutrition = await page.$$eval('.mb-5.flex.flex-col.divide-y > div', (divs) => {
                        const nutritionData = {};
                        
                        divs.forEach(div => {
                            // Handle main nutrition items (bold headers)
                            const mainItem = div.querySelector('.grid.grid-cols-2.py-3.font-bold');
                            if (mainItem) {
                                const label = mainItem.querySelector('span:first-child').textContent.trim();
                                const value = mainItem.querySelector('span:last-child').textContent.trim();
                                nutritionData[label] = value;
                            }

                            // Handle sub-items (indented values)
                            const subItems = div.querySelectorAll('.grid.grid-cols-2.px-3.pb-3');
                            subItems.forEach(subItem => {
                                const label = subItem.querySelector('span:first-child').textContent.trim();
                                const value = subItem.querySelector('span:last-child').textContent.trim();
                                nutritionData[label] = value;
                            });

                            // Handle vitamin/mineral items
                            const vitaminItem = div.querySelector('.grid.grid-cols-2.py-3:not(.font-bold)');
                            if (vitaminItem) {
                                const label = vitaminItem.querySelector('span:first-child').textContent.trim();
                                const value = vitaminItem.querySelector('span:last-child').textContent.trim();
                                nutritionData[label] = value;
                            }
                        });

                        return nutritionData;
                    });

                    if (nutrition) {
                        console.log('Nutrition items found:', Object.keys(nutrition).length);
                    }
                }
            } catch (error) {
                console.error('Error extracting nutrition information:', error);
            }

            return {
                ingredients,
                method,
                nutrition
            };
        } else if (isHappyFoodie) {
            console.log(`Detected ${Sites.HAPPY_FOODIE.name} recipe site`);
            
            // Wait for initial page load
            await page.waitForLoadState('domcontentloaded');
            await new Promise(resolve => setTimeout(resolve, 2000));

            // Extract ingredients
            try {
                const ingredientRows = await page.$$('.hf-ingredients__container table tr');
                if (ingredientRows.length > 0) {
                    ingredients = {
                        main: [],
                        garnishes: []
                    };

                    for (const row of ingredientRows) {
                        const amount = await row.$eval('td:first-child', el => el.textContent.trim());
                        const ingredient = await row.$eval('td:last-child', el => el.textContent.trim());
                        const fullIngredient = amount ? `${amount} ${ingredient}` : ingredient;
                        ingredients.main.push(fullIngredient);
                    }
                    console.log(`Found ${ingredients.main.length} ingredients`);
                }
            } catch (error) {
                console.log('Error extracting ingredients:', error.message);
            }

            // Extract method steps
            try {
                const methodParagraphs = await page.$$('.hf-method__text p');
                if (methodParagraphs.length > 0) {
                    method = await Promise.all(methodParagraphs.map(async p => {
                        const text = await p.textContent();
                        return text.trim()
                            .replace(/\s+/g, ' ')
                            .replace(/\n/g, ' ');
                    }));
                    console.log(`Found ${method.length} method steps`);
                }
            } catch (error) {
                console.log('Error extracting method steps:', error.message);
            }

            // The Happy Foodie doesn't have nutrition info
            nutrition = null;
            console.log('No nutrition data available for The Happy Foodie recipes');

            // Only return if we have the minimum required data
            if (ingredients.main.length === 0 || method.length === 0) {
                throw new Error('Failed to extract required recipe data');
            }

            return {
                ingredients,
                method,
                nutrition
            };
        } else if (Sites.isGoodTo(url)) {
            console.log(`Detected ${Sites.GOOD_TO.name} recipe site`);
            const result = await Sites.scrapeGoodTo(page);
            if (!result || result.ingredients.main.length === 0 || result.method.length === 0) {
                throw new Error('Failed to extract required recipe data from Good To');
            }
            return result;
        } else {
            // Try generic scraping for unsupported sites
            console.log('Unsupported site, attempting generic scraping...');
            const result = await Sites.tryGenericScraper(page);
            
            if (result && result.ingredients.main.length > 0 && result.method.length > 0) {
                console.log('Successfully extracted recipe using generic scraper');
                return result;
            } else {
                throw new Error('Failed to extract recipe data using generic scraper');
            }
        }

        const result = {
            ingredients,
            method,
            nutrition: null
        };

        if (result.nutrition) {
            console.log('Nutrition items found:', Object.keys(result.nutrition).length);
        } else {
            console.log('Nutrition items found: 0');
        }

        // Close the page but keep the browser open
        await page.close();
        console.log('Closed page after scraping');

        return result;

    } catch (error) {
        console.error('Failed to scrape recipe:', error);
        throw error;
    } finally {
        // Make sure we always close the page even if there's an error
        if (page) {
            await page.close().catch(console.error);
        }
    }
}

async function extractTastemadeIngredients(page) {
    try {
        // Wait for either the ingredients section or the login wall
        await Promise.race([
            page.waitForSelector('[data-testid="recipe-ingredients"]', { timeout: 30000 }),
            page.waitForSelector('.space-y-3.bg-gray-100', { timeout: 30000 })
        ]);

        // Check if we hit a login wall
        const loginWall = await page.$('.space-y-3.bg-gray-100');
        if (loginWall) {
            console.log('Login wall detected - recipe requires authentication');
            return [];
        }

        // If no login wall, proceed with normal extraction
        const ingredients = await page.$$eval('[data-testid="recipe-ingredients"] li', 
            elements => elements.map(el => el.textContent.trim())
        );
        
        return ingredients;
    } catch (error) {
        console.error('Error extracting Tastemade ingredients:', error);
        return [];
    }
}

async function extractTastemadeMethod(page) {
    try {
        // Wait for either the method section or the login wall
        await Promise.race([
            page.waitForSelector('[data-testid="recipe-instructions"] li', { timeout: 30000 }),
            page.waitForSelector('.space-y-3.bg-gray-100', { timeout: 30000 })
        ]);

        // Check if we hit a login wall
        const loginWall = await page.$('.space-y-3.bg-gray-100');
        if (loginWall) {
            console.log('Login wall detected - recipe requires authentication');
            return [];
        }

        // If no login wall, proceed with normal extraction
        const method = await page.$$eval('[data-testid="recipe-instructions"] li',
            elements => elements.map(el => el.textContent.trim())
        );

        return method;
    } catch (error) {
        console.error('Error extracting Tastemade method:', error);
        return [];
    }
}

async function extractTastemadeNutrition(page) {
    try {
        // Click nutrition information button if it exists
        const nutritionButton = await page.$('[data-testid="nutrition-button"]');
        if (nutritionButton) {
            await nutritionButton.click();
            await page.waitForSelector('[data-testid="nutrition-modal"]', { timeout: 5000 });
            
            const nutritionData = await page.$$eval('[data-testid="nutrition-modal"] .nutrition-item',
                elements => {
                    const data = {};
                    elements.forEach(el => {
                        const label = el.querySelector('.label')?.textContent.trim();
                        const value = el.querySelector('.value')?.textContent.trim();
                        if (label && value) {
                            data[label] = value;
                        }
                    });
                    return data;
                }
            );
            
            return nutritionData;
        }
        return null;
    } catch (error) {
        console.error('Error extracting Tastemade nutrition:', error);
        return null;
    }
}

async function main() {
    try {
        // Initialize database
        const db = await initializeDatabase();
        
        // Load recipes from JSON file
        const recipesData = await loadRecipes();
        
        // Ensure we have an array of recipes
        const recipes = Array.isArray(recipesData) ? recipesData : 
                       recipesData.recipes ? recipesData.recipes : 
                       Object.values(recipesData);
        
        if (!Array.isArray(recipes)) {
            throw new Error('Could not extract recipes array from JSON data');
        }
        
        console.log(`Loaded ${recipes.length} recipes from JSON file`);
        
        // Add delay before starting
        await new Promise(resolve => setTimeout(resolve, 2000));
        
        // Filter and scrape supported recipes
        for (const recipe of recipes) {
            const url = recipe.source_url;
            if (!url) {
                console.log('Skipping recipe with no source URL');
                continue;
            }

            if (await isSupportedSite(url)) {
                console.log('\nStarting scrape for URL:', url);
                try {
                    const recipeData = await scrapeRecipe(url);
                    await saveRecipe(db, url, recipeData);
                } catch (error) {
                    console.error(`Failed to scrape or save recipe from ${url}:`, error);
                    continue;
                }
            } else {
                console.log(`Skipping unsupported site: ${url}`);
            }
        }

        // Log database location
        console.log('\n=== Recipe Database Information ===');
        console.log(`Location: ${DB_PATH}`);
        console.log('To view the database, you can use any SQLite viewer');
        console.log('Example query: sqlite3 ~/.recipes.db "SELECT * FROM recipes;"');
        
        // Close database connection
        await db.close();
        
    } catch (error) {
        console.error('Failed to complete recipe scraping:', error);
    }
}

main(); 
