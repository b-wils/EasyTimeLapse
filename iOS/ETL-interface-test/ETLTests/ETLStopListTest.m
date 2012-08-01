#import "TestHelper.h"
#import "ETLStopList.h"

@interface ETLStopListTest : ETLTestCase
{
    ETLStopList *stopList;
    id delegateMock;
}
@end

@implementation ETLStopListTest
- (void)setUpClass {
}

- (void)tearDownClass {
}

- (void)setUp {
    stopList = [[ETLStopList alloc] init];
    MOCKS_FOR(stopList)
        WIRE_PROTOCOL(delegateMock, ETLStopListDelegate, delegate)
    END
}

- (void)tearDown {
    VERIFY_MOCK(delegateMock)
    stopList = nil;
}  

- (void)testGetStopForMs 
{
    assertThat([stopList getStopForMs:1000], is(equalTo(@"1\"")));
    assertThat([stopList getStopForMs:1001], is(equalTo(@"ms")));
}

-(void)testGetStopNumberFor
{
    assertThatUnsignedInteger([stopList getStopNumberFor:@"1\""], is(equalToUnsignedInteger(13)));
    assertThatUnsignedInteger([stopList getStopNumberFor:@"ms"], is(equalToUnsignedInteger(0)));
    assertThatUnsignedInteger([stopList getStopNumberFor:@"not-a-stop"], is(equalToUnsignedInteger(0)));
}

-(void)testGetStopNumber
{
    assertThat([stopList getStopNumber:0], is(equalTo(@"ms")));
    assertThat([stopList getStopNumber:13], is(equalTo(@"1\"")));
    assertThat([stopList getStopNumber:100], is(equalTo(@"ms")));
}

-(void)testGetMsForStop
{
    assertThatUnsignedInteger([stopList getMsForStop:@"ms"], is(equalToUnsignedInteger(0)));
    assertThatUnsignedInteger([stopList getMsForStop:@"1\""], is(equalToUnsignedInteger(1000)));
    assertThatUnsignedInteger([stopList getMsForStop:@"not-a-stop"], is(equalToUnsignedInteger(0)));
}

-(void)testNumberOfComponentsInPickerView
{
    assertThatUnsignedInteger([stopList numberOfComponentsInPickerView:nil], is(equalToUnsignedInteger(1)));
}


-(void)testPickerView_numberOfRowsInComponent
{
    assertThatUnsignedInteger([stopList pickerView:nil numberOfRowsInComponent:0], 
                              is(equalToUnsignedInteger([stopList count])));
}

-(void)testPickerView_titleForRow_forComponent
{
    assertThat([stopList pickerView:nil titleForRow:13 forComponent:0], is(equalTo([stopList getStopNumber:13])));
}

-(void)testPickerView_didSelectRow_inComponent
{
    [[delegateMock expect] didSelectStop:@"1\"" ofMs:1000];
    [stopList pickerView:nil didSelectRow:13 inComponent:0];
    
    [[delegateMock expect] didSelectStop:@"ms" ofMs:0];
    [stopList pickerView:nil didSelectRow:0 inComponent:0];

}

-(void)testGetClosestStopToMs
{
    assertThat([stopList getClosestStopToMs:1500], is(equalTo(@"1\"6")));
    assertThat([stopList getClosestStopToMs:1000], is(equalTo(@"1\"")));
    assertThat([stopList getClosestStopToMs:0], is(equalTo(@"ms")));
    assertThat([stopList getClosestStopToMs:UINT_MAX], is(equalTo(@"30\"")));
}
@end