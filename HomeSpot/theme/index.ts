export const colors = {
  // Primary gradient stops
  gradientStart: '#FF6B35',
  gradientMid: '#F7C59F',
  gradientEnd: '#EFEFD0',

  // Brand
  primary: '#FF6B35',
  primaryDark: '#E5521C',
  primaryLight: '#FF8C5A',
  secondary: '#2EC4B6',
  secondaryDark: '#1A9E92',
  accent: '#FFBF00',
  accentDark: '#CC9900',

  // Surfaces
  background: '#0F0F1A',
  surface: '#1A1A2E',
  surfaceElevated: '#242438',
  card: '#1E1E32',
  cardBorder: '#2E2E4A',

  // Text
  text: '#F0F0FF',
  textSecondary: '#A0A0C0',
  textMuted: '#606080',
  textInverse: '#0F0F1A',

  // Semantic
  success: '#2EC4B6',
  warning: '#FFBF00',
  danger: '#FF4757',
  info: '#5352ED',

  // Tags
  sale: '#FF6B35',
  rent: '#2EC4B6',
};

export const gradients = {
  primary: ['#FF6B35', '#FF4500'] as [string, string],
  secondary: ['#2EC4B6', '#1A9E92'] as [string, string],
  card: ['#1E1E32', '#242438'] as [string, string],
  hero: ['#FF6B35', '#FF1744', '#9C27B0'] as [string, string, string],
  accent: ['#FFBF00', '#FF6B35'] as [string, string],
  dark: ['#0F0F1A', '#1A1A2E'] as [string, string],
};

export const spacing = {
  xs: 4,
  sm: 8,
  md: 16,
  lg: 24,
  xl: 32,
  xxl: 48,
};

export const radius = {
  xs: 4,
  sm: 8,
  md: 12,
  lg: 16,
  xl: 24,
  full: 999,
};

export const typography = {
  display: {
    fontSize: 36,
    fontWeight: '800' as const,
    letterSpacing: -1,
    color: colors.text,
  },
  h1: {
    fontSize: 28,
    fontWeight: '700' as const,
    letterSpacing: -0.5,
    color: colors.text,
  },
  h2: {
    fontSize: 22,
    fontWeight: '700' as const,
    letterSpacing: -0.3,
    color: colors.text,
  },
  h3: {
    fontSize: 18,
    fontWeight: '600' as const,
    color: colors.text,
  },
  body: {
    fontSize: 15,
    fontWeight: '400' as const,
    lineHeight: 22,
    color: colors.text,
  },
  bodySmall: {
    fontSize: 13,
    fontWeight: '400' as const,
    lineHeight: 18,
    color: colors.textSecondary,
  },
  caption: {
    fontSize: 12,
    fontWeight: '500' as const,
    color: colors.textMuted,
    letterSpacing: 0.3,
  },
  label: {
    fontSize: 11,
    fontWeight: '700' as const,
    letterSpacing: 1,
    textTransform: 'uppercase' as const,
  },
  price: {
    fontSize: 26,
    fontWeight: '800' as const,
    letterSpacing: -0.5,
    color: colors.primary,
  },
};

export const shadows = {
  small: {
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.3,
    shadowRadius: 4,
    elevation: 3,
  },
  medium: {
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 6 },
    shadowOpacity: 0.4,
    shadowRadius: 12,
    elevation: 8,
  },
  large: {
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 12 },
    shadowOpacity: 0.5,
    shadowRadius: 24,
    elevation: 16,
  },
  glow: {
    shadowColor: colors.primary,
    shadowOffset: { width: 0, height: 0 },
    shadowOpacity: 0.6,
    shadowRadius: 16,
    elevation: 12,
  },
};
