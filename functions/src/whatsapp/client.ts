import { logger } from 'firebase-functions/v2';

const GRAPH_API_VERSION = 'v20.0';

export interface Button {
  id: string;
  title: string;
}

export interface WhatsAppConfig {
  accessToken: string;
  phoneNumberId: string;
}

const graphUrl = (phoneNumberId: string): string =>
  `https://graph.facebook.com/${GRAPH_API_VERSION}/${phoneNumberId}/messages`;

// Meta strips the leading 9 from Brazilian mobile numbers when delivering
// inbound messages, but sending requires the 13-digit format. Re-inject
// the 9 after the DDD when the number is 12 digits long and starts with 55.
const normalizeBrazilianMobile = (to: string): string => {
  if (to.length === 12 && to.startsWith('55')) {
    return `${to.slice(0, 4)}9${to.slice(4)}`;
  }
  return to;
};

const postToGraph = async (config: WhatsAppConfig, payload: unknown): Promise<void> => {
  const response = await fetch(graphUrl(config.phoneNumberId), {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${config.accessToken}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify(payload),
  });

  if (!response.ok) {
    const body = await response.text();
    logger.error('WhatsApp Graph API error', {
      status: response.status,
      body,
    });
    throw new Error(`WhatsApp API failed: ${response.status}`);
  }
};

const WHATSAPP_TEXT_LIMIT = 4096;

const chunkText = (text: string, limit = WHATSAPP_TEXT_LIMIT): string[] => {
  if (text.length <= limit) return [text];
  const parts: string[] = [];
  let remaining = text;
  while (remaining.length > limit) {
    const slice = remaining.slice(0, limit);
    const lastBreak = slice.lastIndexOf('\n');
    const cut = lastBreak > limit / 2 ? lastBreak : limit;
    parts.push(remaining.slice(0, cut));
    remaining = remaining.slice(cut).trimStart();
  }
  if (remaining.length > 0) parts.push(remaining);
  return parts;
};

export const sendText = async (
  config: WhatsAppConfig,
  to: string,
  body: string,
): Promise<void> => {
  const recipient = normalizeBrazilianMobile(to);
  for (const chunk of chunkText(body)) {
    await postToGraph(config, {
      messaging_product: 'whatsapp',
      recipient_type: 'individual',
      to: recipient,
      type: 'text',
      text: { body: chunk },
    });
  }
};

export const sendInteractiveButtons = async (
  config: WhatsAppConfig,
  to: string,
  body: string,
  buttons: Button[],
): Promise<void> => {
  await postToGraph(config, {
    messaging_product: 'whatsapp',
    recipient_type: 'individual',
    to: normalizeBrazilianMobile(to),
    type: 'interactive',
    interactive: {
      type: 'button',
      body: { text: body.slice(0, 1024) },
      action: {
        buttons: buttons.slice(0, 3).map((b) => ({
          type: 'reply',
          reply: { id: b.id, title: b.title.slice(0, 20) },
        })),
      },
    },
  });
};

export const markAsRead = async (
  config: WhatsAppConfig,
  messageId: string,
): Promise<void> => {
  try {
    await postToGraph(config, {
      messaging_product: 'whatsapp',
      status: 'read',
      message_id: messageId,
    });
  } catch (error) {
    logger.warn('markAsRead failed (non-fatal)', error);
  }
};
