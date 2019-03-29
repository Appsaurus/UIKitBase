//
//  ExampleAppStyle.swift
//  UIKitBase
//
//  Created by Brian Strobach on 10/3/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKitTheme
import UIKitBase
import UIKitBase

public class ExampleAppConfiguration: AppConfiguration{
	override public lazy var style: AppStyleGuide = SemyStyleGuide()
}



//MARK: Example

open class SemyColorScheme: ColorScheme{
    
    internal var s: SemyColorScheme.Type{
        return SemyColorScheme.self
    }
    open override func overrideStoredDefaults(){
        super.overrideStoredDefaults()
        primary = s.mintMojitoGreen
        secondary = s.strawberryDaiquiriRed
        primaryContrast = s.whiteRussian
        neutrals = SemyNeutralsColorScheme()
        text = SemyTextColorScheme()
        functional = SemyFunctionalColorScheme()
    }

	open class SemyNeutralsColorScheme: NeutralColorScheme{
        
        open override func overrideStoredDefaults() {
            super.overrideStoredDefaults()
            light = whiteRussian
            mediumLight = fuzzyGray
            medium = buzzedGray
            mediumDark = hammeredGray
            dark = blackout
            
        }
    
	}

	open class SemyTextColorScheme: NeutralTextColorScheme{
        
        open override func overrideStoredDefaults() {
            super.overrideStoredDefaults()
            light = whiteRussian
            mediumLight = fuzzyGray
            medium = buzzedGray
            mediumDark = hammeredGray
            dark = blackout
            
        }
	}

	open class SemyFunctionalColorScheme: FunctionalColorScheme{
        
        open override func overrideStoredDefaults() {
            super.overrideStoredDefaults()
            success = mintMojitoGreen
            disabled = fuzzyGray
            deselected = fuzzyGray
            error = strawberryDaiquiriRed
            selected = mintMojitoGreen            
        }
	}

	//MARK: Brand color palette.
	//Only to be used internally and referenced abstractly through schemes api. Normally these would be internal, but since this is a pod,
	//and there is no protected access scope, they need to be referencable by subclass schemes in apps via public access.


	public static let mintMojitoGreen: UIColor = UIColor(r: 93.0, g: 215.0, b: 173.0) //seafoamBlue

	public static let darkMintMojitoGreen: UIColor = UIColor(r: 87.0, g: 201.0, b: 162.0) //greenyBlue

	public static let strawberryDaiquiriRed: UIColor = UIColor(r: 255.0, g: 150.0, b: 157.0)


	public static let whiteRussian: UIColor = .white

	//Grays/Blacks from light to dark

	public static let hangoverGray: UIColor = UIColor(r: 246, g: 246, b: 246)

	public static let fuzzyGray: UIColor = UIColor(r: 189, g: 189, b: 189)

	public static let buzzedGray: UIColor = UIColor(r: 161, g: 161, b: 161)

	public static let tipsyGray: UIColor = UIColor(r: 51, g: 51, b: 51)

	public static let hammeredGray: UIColor = UIColor(r: 38.0, g: 38.0, b: 40.0) //darkGrey

	public static let blackout: UIColor = .black



}

open class SemyVendorColorScheme: SemyColorScheme{
	open override lazy var primary: UIColor = s.whiteRussian
}

open class SemyStyleGuide: AppStyleGuide{
	open override lazy var colors: ColorScheme = SemyColorScheme()
	open override lazy var typography: TypographyGuide = SemyTypographyGuide()
}

open class SemyTypographyGuide: TypographyGuide{
	open override lazy var fonts: FontGuide = SemyFontGuide()
}

open class SemyFontGuide: FontGuide{
//	open override lazy var thinName: String? = "Wavehaus-28Thin"
//	open override lazy var lightName: String? = "Wavehaus-42Light"
//	open override lazy var regularName: String? = "Wavehaus-66Book"
//	open override lazy var semiboldName: String? = "Wavehaus-95SemiBold"
//	open override lazy var boldName: String? = "Wavehaus-128Bold"
//	open override lazy var heavyName: String? = "Wavehaus-158ExtraBold"
}
