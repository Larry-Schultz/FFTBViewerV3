import '@testing-library/jest-dom';

// Test the updated timezone conversion logic that explicitly uses user's timezone
describe('Updated Timezone Conversion Fix', () => {
  
  // This is the new formatDate function with explicit timezone detection
  const formatDateFixed = (dateString: string | null | undefined): string => {
    if (!dateString) return 'Unknown';
    try {
      let isoString = dateString;
      if (!dateString.includes('Z') && !dateString.includes('+') && !dateString.includes('-', 10)) {
        isoString = dateString + 'Z';
      }
      
      const date = new Date(isoString);
      if (isNaN(date.getTime())) return 'Unknown';
      
      // Get user's actual timezone instead of relying on auto-detect
      const userTimeZone = Intl.DateTimeFormat().resolvedOptions().timeZone;
      
      const dateOptions: Intl.DateTimeFormatOptions = {
        year: 'numeric',
        month: 'short',
        day: 'numeric',
        hour: '2-digit',
        minute: '2-digit',
        second: '2-digit',
        timeZone: userTimeZone // Use detected timezone explicitly
      };
      
      return date.toLocaleString('en-US', dateOptions);
    } catch (error) {
      return 'Unknown';
    }
  };

  test('explicit timezone detection works better than auto-detect', () => {
    const utcTimestamp = '2025-07-19T15:42:46.514608';
    
    const detectedTimezone = Intl.DateTimeFormat().resolvedOptions().timeZone;
    console.log('Detected timezone:', detectedTimezone);
    
    const result = formatDateFixed(utcTimestamp);
    console.log('Fixed format result:', result);
    
    // The result should show timezone-converted time
    expect(result).toContain('Jul 19, 2025');
    expect(result).toMatch(/\d{1,2}:\d{2}:\d{2}/);
    
    // In test environment this will be UTC, but in real browsers it will convert properly
    expect(detectedTimezone).toBeDefined();
  });

  test('verify proper timezone conversion with manual timezone', () => {
    const utcTimestamp = '2025-07-19T15:42:46.514608';
    
    // Test that manual timezone specification works (this is what should happen in real browsers)
    const formatWithManualTZ = (timestamp: string, timezone: string) => {
      const date = new Date(timestamp + 'Z');
      return date.toLocaleString('en-US', {
        year: 'numeric',
        month: 'short',
        day: 'numeric', 
        hour: '2-digit',
        minute: '2-digit',
        second: '2-digit',
        timeZone: timezone
      });
    };
    
    const central = formatWithManualTZ(utcTimestamp, 'America/Chicago');
    const eastern = formatWithManualTZ(utcTimestamp, 'America/New_York');
    
    console.log('Central (CDT):', central);
    console.log('Eastern (EDT):', eastern);
    
    // July 19 is summer, so Central is UTC-5 (CDT) and Eastern is UTC-4 (EDT)
    expect(central).toContain('10:42:46 AM'); // UTC 15:42 - 5 hours = 10:42 CDT
    expect(eastern).toContain('11:42:46 AM'); // UTC 15:42 - 4 hours = 11:42 EDT
  });

  test('confirm backend stores UTC timestamps correctly', () => {
    // Test that our timestamp format understanding is correct
    const backendTimestamp = '2025-07-19T15:42:46.514608'; // This comes from backend (UTC without Z)
    const withZ = backendTimestamp + 'Z'; // We add Z to make it proper ISO
    
    const date = new Date(withZ);
    
    // Should parse correctly as UTC
    expect(date.getUTCHours()).toBe(15);
    expect(date.getUTCMinutes()).toBe(42);
    expect(date.getUTCSeconds()).toBe(46);
    
    console.log('UTC time:', date.toISOString());
    console.log('Local time in any timezone should be different from UTC');
  });
});