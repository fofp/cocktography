/**
 * Cocktography IRCCloud Content Script (Firefox)
 * Integrates cocktography encoding/decoding with IRCCloud's interface
 */

// Firefox compatibility - use browser API if available, fallback to chrome
const browserAPI = typeof browser !== 'undefined' ? browser : chrome;

let cocktography = null;
let settings = {
    enabled: true,
    strokes: 2,
    mode: 1, // THIN_CHODE
    cockblockSize: 340,
    autoEncode: false,
    autoDecode: true
};

// Track multi-message cockchains by sender
// This handles interleaved messages from multiple users (IRCD throttling)
// Each sender gets their own independent chain: activeCockchains['user1'], activeCockchains['user2'], etc.
const activeCockchains = {};

// Cockchain timeout: clean up incomplete chains after 60 seconds
const COCKCHAIN_TIMEOUT_MS = 60000;

/**
 * Clean up stale cockchains that never completed
 */
function cleanupStaleCockchains() {
    const now = Date.now();
    for (const sender in activeCockchains) {
        const chain = activeCockchains[sender];
        if (now - chain.timestamp > COCKCHAIN_TIMEOUT_MS) {
            console.warn(`Cocktography: Cleaning up stale cockchain from ${sender} (${chain.messages.length} messages)`);
            // Unhide the elements so user can see the raw messages
            chain.elements.forEach(el => {
                el.style.display = '';
                el.classList.remove('cocktography-decoded');
                // DO NOT delete cocktographyProcessed - keep elements marked to prevent re-processing
            });
            delete activeCockchains[sender];
        }
    }
}

// Run cleanup every 10 seconds
setInterval(cleanupStaleCockchains, 10000);

// Load settings from storage
browserAPI.storage.sync.get(settings, (stored) => {
    settings = { ...settings, ...stored };
    console.log('Cocktography settings loaded:', settings);
});

/**
 * Initialize the Cocktography library
 */
async function initCocktography() {
    try {
        // Use embedded dicktionaries (loaded from dicktionaries.js)
        cocktography = new Cocktography();
        await cocktography.initialize(DICKTIONARIES);

        console.log('🍆 Cocktography initialized successfully!');
        return true;
    } catch (error) {
        console.error('Failed to initialize Cocktography:', error);
        return false;
    }
}

/**
 * Find IRCCloud message input (currently visible/active one)
 */
function getMessageInput() {
    // IRCCloud uses textarea with ID like bufferInputViewXXXXXX
    // But it has multiple (one per channel), so we need the visible/active one

    // First, try to find all potential textareas
    const textareas = document.querySelectorAll('textarea[id^="bufferInputView"]');

    if (textareas.length > 0) {
        // If there are multiple, find the visible one
        for (const textarea of textareas) {
            const style = window.getComputedStyle(textarea);
            if (style.display !== 'none' && style.visibility !== 'hidden' && textarea.offsetParent !== null) {
                return textarea;
            }
        }
        // Fallback to first if none are detectably visible
        return textareas[0];
    }

    // Fallback to other selectors
    return document.querySelector('textarea[name="msg"]') ||
           document.querySelector('textarea') ||
           document.querySelector('[contenteditable="true"]') ||
           document.querySelector('input[type="text"]') ||
           document.querySelector('.message-input') ||
           document.querySelector('#message');
}

/**
 * Get all message elements in the current view
 */
function getMessageElements() {
    // IRCCloud uses .messageRow divs with data-msgid attribute for individual messages
    // We MUST filter to only elements with data-msgid to avoid processing child elements
    return document.querySelectorAll('.messageRow[data-msgid], .row.messageRow[data-msgid]');
}

/**
 * Check if a message contains cocktography
 */
function hasCocktography(text) {
    if (!cocktography) return false;
    return text.includes('8=wm=D') || text.includes('8wmD');
}

/**
 * Decode and display a cocktographic message
 */
function decodeMessage(messageElement) {
    if (!cocktography || !settings.autoDecode) return;

    // Extract IRCCloud message metadata from the parent div
    const msgId = messageElement.dataset.msgid || 'unknown';
    const dataName = messageElement.dataset.name || 'unknown';

    // Check if already processed - MUST be first check to prevent duplicates
    if (messageElement.dataset.cocktographyProcessed === 'true') {
        return;
    }

    // Mark as processed IMMEDIATELY to prevent duplicate processing by concurrent scans
    messageElement.dataset.cocktographyProcessed = 'true';
    

    // IRCCloud puts message text in span.content
    const textElement = messageElement.querySelector('span.content, .content, .message-content, .msg-text');
    if (!textElement) return;

    // Get the ORIGINAL cocktographic text (just the chodes, not reply button text)
    let originalCocktographicText = '';

    // Get all text nodes directly, excluding button text
    const walker = document.createTreeWalker(
        textElement,
        NodeFilter.SHOW_TEXT,
        null,
        false
    );

    let node;
    while (node = walker.nextNode()) {
        originalCocktographicText += node.textContent;
    }

    if (!hasCocktography(originalCocktographicText)) return;

    // Add visual marker for decoded status
    messageElement.classList.add('cocktography-decoded');

    // Get sender username for tracking cockchains
    const senderElement = messageElement.querySelector('.author, .buffer.bufferLink.author');
    const sender = senderElement ? senderElement.textContent.trim() : 'unknown';

    // Log the text we're trying to detect
    
    const normalizedText = originalCocktographicText.replace(/[\s ]+/g, ' ');
    // Detect cockblock type
    const cockblockInfo = cocktography.findCockblock(normalizedText);

    if (!cockblockInfo) {
        return;
    }

    const cockblockType = cockblockInfo.type;

    try {
        // Handle multi-message cockchains
        if (cockblockType === 2) { // INITIAL
            // If there's already an active chain for this sender, clean it up
            if (activeCockchains[sender]) {
                console.warn(`Cocktography: ${sender} started new chain while previous was incomplete (${activeCockchains[sender].messages.length} messages). Discarding old chain.`);
                // Unhide the old elements so user can see the raw messages
                activeCockchains[sender].elements.forEach(el => {
                    el.style.display = '';
                    el.classList.remove('cocktography-decoded');
                    // DO NOT delete cocktographyProcessed - keep elements marked to prevent re-processing
                });
            }

            // Start a new cockchain
            activeCockchains[sender] = {
                messages: [normalizedText],
                elements: [messageElement],
                timestamp: Date.now()
            };
            // Hide this message temporarily
            messageElement.style.display = 'none';
            return;
        } else if (cockblockType === 3) { // INTERMEDIATE
            // Continue cockchain
            if (activeCockchains[sender]) {
                activeCockchains[sender].messages.push(normalizedText);
                activeCockchains[sender].elements.push(messageElement);
                activeCockchains[sender].timestamp = Date.now(); // Update timestamp to prevent timeout
                // Hide this message temporarily
                messageElement.style.display = 'none';
                return;
            }
            // If we don't have an active chain, treat as standalone
        } else if (cockblockType === 4) { // FINAL
            // Complete cockchain
            if (activeCockchains[sender]) {
                activeCockchains[sender].messages.push(normalizedText);

                // Join messages WITHOUT spaces - kontol chodes create natural boundaries
                const fullMessage = activeCockchains[sender].messages.join('');
                const allElements = activeCockchains[sender].elements;

                // Decode the complete cockchain
                const results = cocktography.dechode(fullMessage, true);

                if (results.length > 0) {
                    const { text, strokes } = results[0];

                    // Display on the FINAL message element with original messages array
                    displayDecodedMessage(messageElement, text, strokes, sender, activeCockchains[sender].messages);

                    // Keep the intermediate messages hidden
                    allElements.forEach(el => {
                        el.style.display = 'none';
                    });
                }

                // Clean up
                delete activeCockchains[sender];
                return;
            }
        }

        // SINGLETON or standalone message - decode immediately
        const results = cocktography.dechode(normalizedText, true);

        if (results.length > 0) {
            const { text, strokes } = results[0];
            displayDecodedMessage(messageElement, text, strokes, sender, normalizedText);
        }
    } catch (error) {
        console.error('Error decoding cocktography:', error);
        // On error, remove visual marker but keep processed flag to prevent re-processing
        messageElement.classList.remove('cocktography-decoded');
        // Clean up any active chain for this sender
        delete activeCockchains[sender];
    }
}

/**
 * Display a decoded message
 */
function displayDecodedMessage(messageElement, text, strokes, sender, messages) {
    const textElement = messageElement.querySelector('span.content, .content, .message-content, .msg-text');
    if (!textElement) return;

    // Preserve the reply button if it exists
    const replyButton = textElement.querySelector('.reply__indicator');
    const replyButtonClone = replyButton ? replyButton.cloneNode(true) : null;

    // Create decoded message display - inline format
    const decodedSpan = document.createElement('span');
    decodedSpan.className = 'cocktography-decoded-message';

    // Create inline header: "5-stroke🍆"
    const strokesSpan = document.createElement('span');
    strokesSpan.className = 'cocktography-strokes';
    strokesSpan.textContent = `${strokes}-stroke`;

    const iconSpan = document.createElement('span');
    iconSpan.className = 'cocktography-icon';
    iconSpan.textContent = '🍆';

    const contentSpan = document.createElement('span');
    contentSpan.className = 'cocktography-content';
    contentSpan.textContent = text;

    decodedSpan.appendChild(strokesSpan);
    decodedSpan.appendChild(iconSpan);
    decodedSpan.appendChild(contentSpan);

    // Add original messages as collapsible - one per line with username
    const originalDetails = document.createElement('details');
    originalDetails.className = 'cocktography-original';

    const summary = document.createElement('summary');
    summary.textContent = 'Show original';

    const originalContent = document.createElement('div');
    originalContent.className = 'cocktography-original-content';

    // Format each message on its own line with <username> prefix
    if (Array.isArray(messages)) {
        messages.forEach(msg => {
            const line = document.createElement('div');
            line.textContent = `<${sender}> ${msg}`;
            originalContent.appendChild(line);
        });
    } else {
        // Singleton message - just show with username
        const line = document.createElement('div');
        line.textContent = `<${sender}> ${messages}`;
        originalContent.appendChild(line);
    }

    originalDetails.appendChild(summary);
    originalDetails.appendChild(originalContent);

    // Clear and rebuild
    textElement.innerHTML = '';
    if (replyButtonClone) {
        textElement.appendChild(replyButtonClone);
    }
    textElement.appendChild(decodedSpan);
    textElement.appendChild(originalDetails);
}

/**
 * Add encode button (fixed position, always visible)
 */
function addEncodeButton() {
    // Check if button already exists AND has handlers attached
    const existingButton = document.getElementById('cocktography-encode-btn');
    if (existingButton && existingButton.dataset.hasHandlers === 'true') {
        return; // Button exists and is properly set up
    }

    // Remove old button if it exists without handlers
    if (existingButton) {
        console.log('Cocktography: Removing old button without handlers');
        existingButton.remove();
    }

    console.log('Cocktography: Adding encode button...');

    const button = document.createElement('button');
    button.id = 'cocktography-encode-btn';
    button.className = 'cocktography-encode-button';
    button.innerHTML = '🍆';
    button.title = 'Encode message with Cocktography (Ctrl+Shift+E)';

    // Inline styles - positioned left of timestamp, aligned with input
    button.style.cssText = `
        position: fixed !important;
        bottom: 23px !important;
        left: 0px !important;
        width: 36px !important;
        height: 36px !important;
        border-radius: 50% !important;
        background: linear-gradient(135deg, rgba(139, 92, 246, 0.4) 0%, rgba(236, 72, 153, 0.4) 100%) !important;
        border: none !important;
        font-size: 18px !important;
        cursor: pointer !important;
        box-shadow: 0 4px 12px rgba(139, 92, 246, 0.3) !important;
        z-index: 999999 !important;
        display: flex !important;
        align-items: center !important;
        justify-content: center !important;
        transition: transform 0.2s !important;
        touch-action: manipulation !important;
        -webkit-tap-highlight-color: transparent !important;
        user-select: none !important;
        -webkit-user-select: none !important;
    `;

    // Hover effect
    button.addEventListener('mouseenter', () => {
        button.style.transform = 'scale(1.2)';
    });
    button.addEventListener('mouseleave', () => {
        button.style.transform = 'scale(1)';
    });

    // Mobile-friendly touch support
    button.addEventListener('touchstart', (e) => {
        e.preventDefault();
        encodeCurrentMessage();
    }, { passive: false });

    button.addEventListener('click', (e) => {
        e.preventDefault();
        e.stopPropagation();
        encodeCurrentMessage();
    }, { capture: true });

    // ALSO add onclick as a backup
    button.onclick = (e) => {
        e.preventDefault();
        e.stopPropagation();
        encodeCurrentMessage();
    };

    // Mark that handlers are attached
    button.dataset.hasHandlers = 'true';

    document.body.appendChild(button);
}

/**
 * Parse inline flags from message text
 * Supports: -sX/--strokes:X (0-12), -m/-w/-t/--mixed/--wide/--thin/--mode:X
 * Returns: {strokes, mode, text} with flags stripped from text
 */
function parseMessageFlags(text) {
    // Mode constants (from cpi.js)
    const THIN_CHODE = 1;
    const WIDE_CHODE = 2;
    const MIXED_CHODE = 3;

    let strokes = null;
    let detectedModes = [];
    let cleanedText = text;

    // Define flag patterns
    const strokePatterns = [
        /^-s(\d{1,2})\s+/,           // -s4 Hello
        /^--strokes:(\d{1,2})\s+/    // --strokes:4 Hello
    ];

    const modePatterns = [
        // Mixed mode (highest precedence = 3)
        { pattern: /^-m\s+/, mode: MIXED_CHODE },
        { pattern: /^--mixed\s+/, mode: MIXED_CHODE },
        { pattern: /^--mode:mixed\s+/, mode: MIXED_CHODE },
        { pattern: /^--mode:m\s+/, mode: MIXED_CHODE },
        // Wide mode (precedence = 2)
        { pattern: /^-w\s+/, mode: WIDE_CHODE },
        { pattern: /^--wide\s+/, mode: WIDE_CHODE },
        { pattern: /^--mode:wide\s+/, mode: WIDE_CHODE },
        { pattern: /^--mode:w\s+/, mode: WIDE_CHODE },
        // Thin mode (lowest precedence = 1)
        { pattern: /^-t\s+/, mode: THIN_CHODE },
        { pattern: /^--thin\s+/, mode: THIN_CHODE },
        { pattern: /^--mode:thin\s+/, mode: THIN_CHODE },
        { pattern: /^--mode:t\s+/, mode: THIN_CHODE }
    ];

    // Parse all flags (order doesn't matter, we handle precedence later)
    let foundFlag = true;
    while (foundFlag) {
        foundFlag = false;

        // Try stroke patterns
        for (const pattern of strokePatterns) {
            const match = cleanedText.match(pattern);
            if (match) {
                const value = parseInt(match[1], 10);
                if (value >= 0 && value <= 12) {
                    strokes = value;
                    cleanedText = cleanedText.replace(pattern, '');
                    foundFlag = true;
                    break;
                }
            }
        }

        // Try mode patterns
        for (const { pattern, mode } of modePatterns) {
            const match = cleanedText.match(pattern);
            if (match) {
                detectedModes.push(mode);
                cleanedText = cleanedText.replace(pattern, '');
                foundFlag = true;
                break;
            }
        }
    }

    // Apply mode precedence: mixed (3) > wide (2) > thin (1)
    let selectedMode = null;
    if (detectedModes.length > 0) {
        selectedMode = Math.max(...detectedModes);
    }

    return {
        strokes: strokes,
        mode: selectedMode,
        text: cleanedText.trim()
    };
}

/**
 * Encode the current message in the input
 */
function encodeCurrentMessage() {

    if (!cocktography) {
        console.error('Cocktography: Not initialized!');
        alert('Cocktography not initialized yet!\nCheck the console (F12) for errors.');
        return;
    }

    const input = getMessageInput();

    if (!input) {
        console.error('Cocktography: No input element found!');
        alert('Could not find message input!\nMake sure you\'re in a channel.');
        return;
    }

    const text = input.value || input.textContent || input.innerText;

    if (!text || !text.trim()) {
        console.warn('Cocktography: Input is empty');
        alert('Type a message first!');
        return;
    }

    try {
        // Parse inline flags from message
        const parsed = parseMessageFlags(text);
        
        // Use parsed values or fall back to settings
        const strokesToUse = parsed.strokes !== null ? parsed.strokes : settings.strokes;
        const modeToUse = parsed.mode !== null ? parsed.mode : settings.mode;
        const textToEncode = parsed.text;

        const encoded = cocktography.enchode(
            textToEncode,
            strokesToUse,
            modeToUse,
            settings.cockblockSize
        );


        // Set the encoded message
        if (input.value !== undefined) {
            input.value = encoded;
        } else if (input.textContent !== undefined) {
            input.textContent = encoded;
        } else {
            input.innerText = encoded;
        }

        // Trigger multiple events to ensure IRCCloud notices
        input.dispatchEvent(new Event('input', { bubbles: true }));
        input.dispatchEvent(new Event('change', { bubbles: true }));
        input.focus();

        console.log('✅ Cocktography: Message encoded successfully!');

        // Show brief confirmation
        const button = document.getElementById('cocktography-encode-btn');
        if (button) {
            button.innerHTML = '✓';
            setTimeout(() => {
                button.innerHTML = '🍆';
            }, 1000);
        }
    } catch (error) {
        console.error('❌ Cocktography: Error encoding:', error);
        alert('Failed to encode message:\n' + error.message);
    }
}

/**
 * Watch for new messages
 */
function observeMessages() {
    // IRCCloud uses .log for the message container
    const messageContainer = document.querySelector('.log, .messages, .message-list, #messages, .buffercontainer');
    if (!messageContainer) {
        console.log('Message container not found, retrying...');
        setTimeout(observeMessages, 1000);
        return;
    }

    console.log('Message container found:', messageContainer);

    // Decode existing messages
    const existingMessages = getMessageElements();
    existingMessages.forEach(decodeMessage);

    // Watch for new messages
    const observer = new MutationObserver((mutations) => {
        for (const mutation of mutations) {
            for (const node of mutation.addedNodes) {
                if (node.nodeType === Node.ELEMENT_NODE) {
                    // Check if this node is a message row with data-msgid
                    if (node.matches && node.matches('.messageRow[data-msgid], .row.messageRow[data-msgid]')) {
                        decodeMessage(node);
                    }
                    // Check children for message rows (but not recursively to avoid duplicates)
                    else if (node.querySelectorAll) {
                        const messageRows = node.querySelectorAll('.messageRow[data-msgid], .row.messageRow[data-msgid]');
                        messageRows.forEach(decodeMessage);
                    }
                }
            }
        }
    });

    try {
        observer.observe(messageContainer, {
            childList: true,
            subtree: true  // Watch entire subtree to catch messages added anywhere in the container
        });
        console.log('✅ MutationObserver successfully attached!');
    } catch (error) {
        console.error('❌ Failed to attach MutationObserver:', error);
    }

    // POLLING FALLBACK: IRCCloud might use a framework that doesn't trigger mutations
    // Scan for new messages every 500ms
    console.log('🔄 Starting polling fallback (checks every 500ms for new messages)');
    setInterval(() => {
        const messages = getMessageElements();
        messages.forEach(decodeMessage);
    }, 500);

    console.log('🍆 Watching for cocktography messages');
}

/**
 * Initialize UI enhancements
 */
function initUI() {

    // Add button immediately
    setTimeout(() => {
        addEncodeButton();
    }, 100);

    // Re-check periodically
    setInterval(() => {
        addEncodeButton();
    }, 3000);
}

/**
 * Keyboard shortcut handler
 */
document.addEventListener('keydown', (e) => {
    // Ctrl+Shift+E = Encode (try multiple key variations)
    if ((e.ctrlKey || e.metaKey) && e.shiftKey && (e.key === 'E' || e.key === 'e' || e.code === 'KeyE')) {
        e.preventDefault();
        e.stopPropagation();
        encodeCurrentMessage();
        return false;
    }
}, true);  // Use capture phase to get event before IRCCloud


/**
 * Listen for settings updates
 */
browserAPI.storage.onChanged.addListener((changes, namespace) => {
    if (namespace === 'sync') {
        for (const [key, { newValue }] of Object.entries(changes)) {
            if (key in settings) {
                settings[key] = newValue;
                console.log(`Setting updated: ${key} = ${newValue}`);
            }
        }
    }
});

/**
 * Main initialization
 */
async function init() {
    console.log('🍆 Cocktography extension loading...');

    const initialized = await initCocktography();
    if (!initialized) {
        console.error('Failed to initialize Cocktography');
        return;
    }

    // Wait for IRCCloud to load
    setTimeout(() => {
        observeMessages();
        initUI();
    }, 1000);
}

// Start when page is ready
if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
} else {
    init();
}
