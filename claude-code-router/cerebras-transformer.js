// Custom transformer for Cerebras to handle Claude Code's message format

const fs = require('fs');
const path = require('path');
const os = require('os');

/**
 * Converts content from Claude Code format (array of objects) to plain string
 */
function convertContentToString(content) {
  if (typeof content === 'string') {
    return content;
  }

  if (Array.isArray(content)) {
    return content
      .map(item => {
        if (typeof item === 'string') {
          return item;
        }
        if (item.type === 'text' && item.text) {
          return item.text;
        }
        return '';
      })
      .join('');
  }

  return '';
}

class CerebrasTransformer {
  constructor() {
    this.name = 'cerebras';
    this.apiKey = this.loadApiKey();
  }

  loadApiKey() {
    try {
      // Read key from ~/.dotfiles.env directly (server daemon doesn't have shell env vars)
      const envPath = path.join(os.homedir(), '.dotfiles.env');
      const envContent = fs.readFileSync(envPath, 'utf8');
      const match = envContent.match(/^CEREBRAS_API_KEY="?([^"\n]+)"?/m);
      if (match) return match[1];
      return '';
    } catch (e) {
      return '';
    }
  }

  async transformRequestIn(request, provider) {
    const transformedRequest = JSON.parse(JSON.stringify(request));

    // Remove reasoning field (Cerebras doesn't support it)
    if (transformedRequest.reasoning !== undefined) {
      delete transformedRequest.reasoning;
    }

    // Transform messages - convert content arrays to strings
    if (transformedRequest.messages && Array.isArray(transformedRequest.messages)) {
      transformedRequest.messages = transformedRequest.messages.map(message => {
        const transformedMessage = { ...message };
        if (message.content !== undefined) {
          transformedMessage.content = convertContentToString(message.content);
        }
        return transformedMessage;
      });
    }

    // Handle top-level system field
    if (transformedRequest.system !== undefined) {
      transformedRequest.system = convertContentToString(transformedRequest.system);
    }

    return {
      body: transformedRequest,
      config: {
        headers: {
          'Authorization': `Bearer ${this.apiKey}`,
          'Content-Type': 'application/json'
        }
      }
    };
  }

  async transformResponseOut(response) {
    return response;
  }
}

module.exports = CerebrasTransformer;
module.exports.default = CerebrasTransformer;
