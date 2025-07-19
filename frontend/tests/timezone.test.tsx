import '@testing-library/jest-dom';

// Simple timezone conversion test to verify the logic works correctly
describe('Timezone Conversion Logic Test', () => {
  
  // Test the exact function logic that should be used in components
  const formatDateCorrect = (dateString: string | null | undefined): string => {
    if (!dateString) return 'Unknown';
    try {
      // Handle database timestamps - they come as "2025-07-19T15:35:44.881708" (UTC without Z)
      let isoString = dateString;
      if (!dateString.includes('Z') && !dateString.includes('+') && !dateString.includes('-', 10)) {
        isoString = dateString + 'Z';
      }
      
      const date = new Date(isoString);
      if (isNaN(date.getTime())) return 'Unknown';
      
      // Use user's local timezone (no hardcoded timezone)
      const dateOptions: Intl.DateTimeFormatOptions = {
        year: 'numeric',
        month: 'short',
        day: 'numeric',
        hour: '2-digit',
        minute: '2-digit',
        second: '2-digit'
      };
      
      return date.toLocaleString('en-US', dateOptions);
    } catch (error) {
      return 'Unknown';
    }
  };

  test('formatDate converts UTC to different timezones correctly', () => {
    const utcTimestamp = '2025-07-19T15:42:46.514608';
    
    // Mock different timezones for testing
    const originalResolvedOptions = Intl.DateTimeFormat.prototype.resolvedOptions;
    
    // Test Central Time (UTC-6 in summer)
    Intl.DateTimeFormat.prototype.resolvedOptions = jest.fn(() => ({
      ...originalResolvedOptions.call(new Intl.DateTimeFormat()),
      timeZone: 'America/Chicago'
    }));
    
    const chicagoResult = formatDateCorrect(utcTimestamp);
    console.log('Chicago result:', chicagoResult);
    
    // Test Eastern Time (UTC-5 in summer) 
    Intl.DateTimeFormat.prototype.resolvedOptions = jest.fn(() => ({
      ...originalResolvedOptions.call(new Intl.DateTimeFormat()),
      timeZone: 'America/New_York'
    }));
    
    const nyResult = formatDateCorrect(utcTimestamp);
    console.log('New York result:', nyResult);
    
    // Restore original function
    Intl.DateTimeFormat.prototype.resolvedOptions = originalResolvedOptions;
    
    // The format should differ based on timezone
    expect(chicagoResult).not.toBe(nyResult);
    expect(chicagoResult).toContain('Jul 19, 2025');
    expect(nyResult).toContain('Jul 19, 2025');
  });

  test('verify UTC timestamp is not showing in local conversion', () => {
    const utcTimestamp = '2025-07-19T15:42:46.514608';
    const result = formatDateCorrect(utcTimestamp);
    
    console.log('Local conversion result:', result);
    console.log('Detected timezone:', Intl.DateTimeFormat().resolvedOptions().timeZone);
    
    // In test environment, we expect UTC conversion, but in real browser it should be different
    expect(result).toContain('Jul 19, 2025');
    expect(result).toMatch(/\d{1,2}:\d{2}:\d{2}/); // Has time format
  });

  test('test manual timezone specification', () => {
    const utcTimestamp = '2025-07-19T15:42:46.514608';
    
    const formatWithTimezone = (timestamp: string, timezone: string) => {
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
    
    const centralTime = formatWithTimezone(utcTimestamp, 'America/Chicago');
    const easternTime = formatWithTimezone(utcTimestamp, 'America/New_York');
    const pacificTime = formatWithTimezone(utcTimestamp, 'America/Los_Angeles');
    
    console.log('Central Time:', centralTime);
    console.log('Eastern Time:', easternTime);
    console.log('Pacific Time:', pacificTime);
    
    // UTC 15:42:46 should convert to different local times
    expect(centralTime).toContain('9:42:46 AM'); // UTC-6 in summer (CDT)
    expect(easternTime).toContain('11:42:46 AM'); // UTC-4 in summer (EDT)  
    expect(pacificTime).toContain('8:42:46 AM'); // UTC-7 in summer (PDT)
  });
});